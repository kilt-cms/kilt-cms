Rails.application.routes.draw do

	mount Kilt::Engine => '/admin'

	get '/' => 'dummy#index'
  
end
