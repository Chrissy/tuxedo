Tuxno2::Application.routes.draw do
  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'indexes#home'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  get 'new' => 'recipes#new'
  get ':id' => 'recipes#show', as: :recipe
  get 'edit/:id' => 'recipes#edit', as: :edit
  post 'update/:id' => 'recipes#update', as: :update
  post 'create' => 'recipes#create', as: :create
  get 'delete/:id' => 'recipes#delete'

  get 'components/all' => 'components#all'
  get 'components/new' => 'components#new'
  get 'components/:id' => 'components#show'
  get 'components/edit/:id' => 'components#edit'
  post 'components/update/:id' => 'components#update'
  post 'components/create' => 'components#create'

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
