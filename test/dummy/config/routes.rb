Rails.application.routes.draw do

	mount Kilt::Engine => '/admin', as: 'kilt_engine'

	get '/' => 'dummy#index'
  
end
