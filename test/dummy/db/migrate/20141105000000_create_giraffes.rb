class CreateGiraffes < ActiveRecord::Migration
  def change
    create_table :giraffes do |t|
      t.string :first_name
      t.string :last_name
      t.string :city
      t.string :state
      t.string :height

      t.timestamps
    end
  end
end
