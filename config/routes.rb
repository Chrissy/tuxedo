Tuxno2::Application.routes.draw do
  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'lists#home'
  get 'admin' => 'lists#admin'

  get 'new' => 'recipes#new'
  get 'all' => 'recipes#all'
  get 'search' => 'recipes#search'
  
  get 'edit/:id' => 'recipes#edit', as: :edit
  post 'update/:id' => 'recipes#update', as: :update
  post 'create' => 'recipes#create', as: :create
  get 'delete/:id' => 'recipes#delete'

  get 'ingredients/all' => 'components#all'
  get 'ingredients/new' => 'components#new'
  get 'ingredients/:id' => 'components#show'
  get 'ingredients/edit/:id' => 'components#edit'
  post 'ingredients/update/:id' => 'components#update'
  post 'ingredients/create' => 'components#create'
  get 'ingredients/delete/:id' => 'components#delete'

  get 'list/new' => 'lists#new'
  get 'list/all' => 'lists#all'
  get 'list/:id' => 'lists#show'
  get 'list/get/:id' => 'lists#get'
  get 'list/edit/:id' => 'lists#edit'
  post 'list/update/:id' => 'lists#update'
  post 'list/create' => 'lists#create'
  get 'list/delete/:id' => 'lists#delete'
  
  get '404', :to => 'lists#not_found'
  get '422', :to => 'lists#not_found'
  get '500', :to => 'lists#not_found'
  
  get ':id' => 'recipes#show', as: :recipe

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
