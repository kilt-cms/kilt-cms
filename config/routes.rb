Kilt::Engine.routes.draw do
  
  root 'kilt#index'
  
  get     '/'              => 'kilt#index',    :as => 'home'
  get     '/:types'        => 'kilt#list',     :as => 'list'
  get     '/:types/new'    => 'kilt#new',      :as => 'new_object'
  post    '/:types'        => 'kilt#create',   :as => 'create_object'
  get     '/:types/:slug'  => 'kilt#edit',     :as => 'edit_object'
  post    '/:types/:slug'  => 'kilt#update',   :as => 'update_object'
  delete  '/:types/:slug'  => 'kilt#delete',   :as => 'delete_object'
  
end
