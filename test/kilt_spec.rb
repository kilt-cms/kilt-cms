require File.expand_path(File.dirname(__FILE__) + '/minitest_helper')

describe Kilt do

  before do
    clear_out_the_database
  end

  describe "types" do

    it "should return the keys from the objects in the Kilt config" do
      keys = default_test_config.objects.map { |k, _| k }
      Kilt.types.must_equal keys
    end

  end

  persistence_models_to_test = [['using active record for persistence', :active_record]]
  unless ENV['TRAVIS']
    persistence_models_to_test << ['using rethinkdb for persistence', :rethinkdb]
  end

  persistence_models_to_test.map { |args| Struct.new(:description, :db_type).new(*args) }.each do |persistence|

    describe persistence.description do

      before do
        Kilt::Utils.use_db persistence.db_type
      end

      describe "creating an object" do

        [
          ['1/1/2014', 'cat', 'Apple',  Time.parse('1/1/2014').to_i.to_s + "000", 'apple' ],
          ['2/2/2016', 'dog', 'Orange', Time.parse('2/2/2016').to_i.to_s + "000", 'orange'],
        ].map { |v| Struct.new(:today, :type, :name, :unique_id, :slug).new *v }.each do |scenario|

          describe "basic scenarios" do

            let(:values) { {} }

            let(:object) do
              Kilt::Object.new(scenario.type, values)
            end

            before do
              Timecop.freeze Time.parse(scenario.today)
              values['name'] = scenario.name
            end

            it "should set a unique id based on time" do
              Kilt.create(object)
              object['unique_id'].must_equal scenario.unique_id
            end

            it "should set the name" do
              Kilt.create(object)
              object['name'].must_equal scenario.name
            end

            it "should create an object that can be retrieved out of the database again" do
              Kilt.create(object)
              fresh = Kilt.get(object['slug'])
              fresh['unique_id'].must_equal object['unique_id']
            end

            it "should set the type of the object" do
              Kilt.create(object)
              object['type'].must_equal scenario.type
              Kilt.get(object['slug'])['type'].must_equal scenario.type
            end

            it "should set the created_at" do
              Kilt.create(object)
              object['created_at'].must_equal Time.parse(scenario.today)
              Kilt.get(object['slug'])['created_at'].must_equal Time.parse(scenario.today)
            end

            it "should set the updated_at" do
              Kilt.create(object)
              object['updated_at'].must_equal Time.parse(scenario.today)
              Kilt.get(object['slug'])['updated_at'].must_equal Time.parse(scenario.today)
            end

            it "should set a slug on the object" do
              Kilt.create(object)
              object['slug'].must_equal scenario.slug
            end

            if persistence.db_type == :active_record
              it "should set the unique_id for the object" do
                Kilt.create(object)
                KiltObject.first.unique_id.must_equal object['unique_id']
              end
            end

            describe "creating the record twice" do

              it "should keep the slugs unique by appending the id to the second record" do

                first  = Kilt::Object.new(scenario.type, values)
                second = Kilt::Object.new(scenario.type, values.clone)

                Kilt.create(first)
                Timecop.freeze(Time.now + 5)
                Kilt.create(second)

                first['slug'].must_equal scenario.slug
                second['slug'].must_equal "#{scenario.slug}-#{second['unique_id']}"

              end

            end

          end

        end

        [1, 2, 3, 4].each do |error_count|

          describe "when creating a record fails" do
            if persistence.db_type == :active_record
              it "should return false" do
                KiltObject.stubs(:create!).raises 'error'
                object = Kilt::Object.new('dog', { 'name' => 'A name.' } )
                Kilt.create(object).must_equal false
              end
            else
              it "should return false" do
                Kilt::DB::RethinkDb.any_instance.stubs(:execute).returns( { 'errors' => error_count } )
                object = Kilt::Object.new('dog', { 'name' => 'A name.' } )
                Kilt.create(object).must_equal false
              end
            end
          end

        end

      end

      describe "updating an object" do

        [
          ['1/1/2012', '2/3/2012', 'cat', 'test',  'something_else', 'A', 'B', 'test'],
          ['2/3/2014', '5/3/2015', 'dog', 'apple', 'orange',         'L', 'S', 'apple'],
        ].map do |values|
          Struct.new(:created_at, :updated_at, :type, :original_name, :new_name, :original_size, :new_size, :original_slug).new *values
        end.each do |scenario|

          describe "basic scenarios" do

            let(:values) { { 
                             'name' => scenario.original_name,
                             'size' => scenario.original_size
                           } }

            let(:object) do
              Kilt::Object.new(scenario.type, values)
            end

            before do
              Kilt.create(object)
              Timecop.freeze Time.parse(scenario.created_at)
              values['name'] = scenario.new_name
              values['size'] = scenario.new_size
            end

            it "should use the updated at date" do
              new_date = Time.parse(scenario.updated_at)

              Timecop.freeze new_date
              Kilt.update object.slug, object
              object['updated_at'].must_equal new_date
              Kilt.get(object['slug'])['updated_at'].must_equal new_date
            end

            it "should update the name" do
              Kilt.update object.slug, object

              object['name'].must_equal scenario.new_name
              Kilt.get(object['slug'])['name'].must_equal scenario.new_name
            end

            it "should update the size" do
              Kilt.update object.slug, object

              object['size'].must_equal scenario.new_size
              Kilt.get(object['slug'])['size'].must_equal scenario.new_size
            end

            it "should NOT update the slug" do
              Kilt.update object.slug, object

              object['slug'].must_equal scenario.original_slug
            end

          end

        end

        describe "updating the slug" do

          describe "when the slug is unique" do

            it "should update the slug" do

              object = Kilt::Object.new('cat', { 'name' => 'test' } )
              Kilt.create object

              original_slug = object['slug']

              object['slug'] = 'different'
              Kilt.update original_slug, object

              Kilt.get(object['slug'])['unique_id'].must_equal object['unique_id']
            end

          end

          describe "when the slug is not unique" do

            before do
              Timecop.freeze Time.parse('1/1/2014')
            end

            it "should change the slug to a unique value" do

              first = Kilt::Object.new('cat', { 'name' => 'first' } )
              Kilt.create first

              # have to update the time, as the unique id is time-based
              Timecop.freeze Time.now + 1

              second = Kilt::Object.new('cat', { 'name' => 'second' } )
              Kilt.create second

              slug = first['slug']

              first['slug'] = second['slug']
              Kilt.update 'first', first

              first['slug'].must_equal 'second-' + Time.now.to_i.to_s + "000"
            end

          end

          [
            ['do_not_clear_me', nil],
            ['do_not_clear_me', ''],
            ['do_not_clear_me', '   '],
          ].map { |a| Struct.new(:name, :invalid_value).new *a }.each do |scenario|

            describe "when the slug is removed" do

              before do
                Timecop.freeze Time.parse('1/1/2014')
              end

              it "should keep a valid slug" do

                clear_out_the_database

                first = Kilt::Object.new('cat', { 'name' => scenario.name } )
                Kilt.create first

                slug = first['slug']

                first['slug'] = scenario.invalid_value
                Kilt.update slug, first

                first['slug'].must_equal slug
              end

            end

            describe "when the slug is removed and the slug will collide with another" do

              before do
                Timecop.freeze Time.parse('1/1/2014')
                clear_out_the_database
              end

              it "should keep a valid slug" do

                clear_out_the_database

                first = Kilt::Object.new('dog', { 'name' => 'a unique value' } )
                Kilt.create first

                Timecop.freeze Time.now + 1

                second = Kilt::Object.new('dog', { 'name' => scenario.name } )
                Kilt.create second

                slug = first['slug']

                first['name'] = scenario.name
                first['slug'] = scenario.invalid_value
                Kilt.update slug, first

                first['slug'].must_equal second['slug'] + '-' + Time.now.to_i.to_s + "000"
              end

            end

          end

        end

      end

      [
        ['dog', 'rover'],
        ['cat', 'fluffy'],
        ['dog', 'x'],
        ['cat', 'y']
      ].map { |args| Struct.new(:type, :name).new(*args) }.each do |scenario|

        describe "getting an object" do

          it "should return the object" do
            object = Kilt::Object.new(scenario.type, { 'name' => scenario.name } )
            Kilt.create object

            result = Kilt.get object['slug']

            result['unique_id'].must_equal object['unique_id']
          end

          it "should return a kilt object" do
            object = Kilt::Object.new(scenario.type, { 'name' => scenario.name } )
            Kilt.create object

            result = Kilt.get object['slug']

            result.is_a? Kilt::Object
          end

          describe "no match" do
            it "should return nil" do
              Kilt.get(scenario.name).nil?.must_equal true
            end
          end

        end

      end

      describe "get collection" do

        it "should return an object collection" do
          Kilt.get_collection('cat').is_a?(Kilt::ObjectCollection).must_equal true
        end

        [
          ['cat',  'cat'],
          ['dog',  'dog'],
          ['cats', 'cat'],
          ['dogs', 'dog'],
        ].map { |args| Struct.new(:type, :singular_type).new(*args) }.each do |scenario|

          describe "objects exist" do
            before do
              Timecop.freeze Time.parse('3/4/2018')
              ['dog', 'cat'].each do |type|
                (1..4).map { |x| Kilt::Object.new(type, { 'name' => "#{type}#{x}" } ) }
                      .each do |object|
                              Timecop.freeze Time.now + 5
                              Kilt.create object
                            end
              end
            end

            it "should return only the objects tied to this type" do
              results = Kilt.get_collection scenario.type
              results.count.must_equal 4
              results.each { |x| x['type'].must_equal scenario.singular_type }
            end

          end

        end

      end

      describe "delete" do

        let(:object) do
          o = Kilt::Object.new('cat', { 'name' => 'Anthem' })
          Kilt.create o
          o
        end

        it "should remove the record from the database" do
          Kilt.delete object['slug']

          Kilt.get(object['slug']).nil?.must_equal true
        end

        it "should return true if the delete did not error" do
          Kilt.delete(object['slug']).must_equal true
        end

        if persistence.db_type == :active_record
          it "should return false if the delete returned errors" do
            KiltObject.any_instance.stubs(:delete).raises 'error'
            Kilt.delete(object['slug']).must_equal false
          end
        else
          it "should return false if the delete returned errors" do
            Kilt::DB::RethinkDb.any_instance.stubs(:execute).returns( { 'errors' => 1 } )
            Kilt.delete(object['slug']).must_equal false
          end
        end

      end

    end

  end

  describe "slug prefixes" do

    [
      ['prefix_holder',  :prefix_holders,   'Happy Camper',  'a-prefix-happy-camper', 'a-prefix'],
      ['another_prefix', :another_prefixes, 'Happy Camper',  'another-happy-camper',  'another'],
      ['prefix_holder',  :prefix_holders,   'Sad Camper',    'a-prefix-sad-camper',   'a-prefix'],
      ['another_prefix', :another_prefixes, 'Amused Camper', 'another-amused-camper', 'another'],
    ].map { |x| Struct.new(:type, :plural_type, :name, :expected_slug, :the_prefix).new(*x) }.each do |scenario|

      describe "creating an object with a slug prefix" do

        it "should prepend the slug prefix to the slug" do
          object = Kilt::Object.new(scenario.type, { 'name' => scenario.name } )
          Kilt.create object

          object['slug'].must_equal scenario.expected_slug
        end

        describe "when creating a record that naturally will conflict with a prefix" do
          it "should still append the appropriate slug" do
            object = Kilt::Object.new(scenario.type, { 'name' => scenario.the_prefix } )

            Kilt.create object

            object['slug'].must_equal "#{scenario.the_prefix}-#{scenario.the_prefix}"
                
          end
        end

      end

      describe "updating the object later" do

        it "should only have one prefix" do
          object = Kilt::Object.new(scenario.type, { 'name' => scenario.name } )
          Kilt.create object

          created_record = Kilt.get(object['slug'])
          first_slug = created_record['slug']

          Kilt.update created_record['slug'], created_record

          updated_record = Kilt.get(created_record['slug'])
          updated_record['slug'].must_equal first_slug

        end

      end

    end

    describe "slug conflicts when applying a prefix" do

      describe "when conflicting with the same type on record creation" do

        it "should use the timestamped suffix" do

          Timecop.freeze Time.parse('1/1/2001')

          object = Kilt::Object.new('another_prefix', { 'name' => 'Apple' } )
          Kilt.create object

          Timecop.freeze Time.now + 1

          object = Kilt::Object.new('another_prefix', { 'name' => 'Apple' } )
          Kilt.create object

          object['slug'].must_equal 'another-apple-978328801000'

        end

      end

    end

  end

end
