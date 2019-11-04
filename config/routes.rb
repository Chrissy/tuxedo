Tuxno2::Application.routes.draw do
  devise_for :users

  root 'lists#home'

  get 'admin' => 'lists#admin'
  get 'about' => 'lists#about'
  get 'index/:letter' => 'indeces#letter_index'
  get 'index' => 'indeces#index'

  get 'ingredients/all' => 'components#all'
  get 'ingredients/new' => 'components#new'
  get 'ingredients/edit/:id' => 'components#edit'
  post 'ingredients/update/:id' => 'components#update'
  post 'ingredients/create' => 'components#create'
  get 'ingredients/delete/:id' => 'components#delete'
  get 'ingredients/:id' => 'components#show'
  get 'ingredients-index/:letter' => 'components#letter_index'
  get 'ingredients' => 'components#index'

  get 'list/new' => 'lists#new'
  get 'list/all' => 'lists#all'
  get 'list/get/:id' => 'lists#get'
  get 'list/edit/:id' => 'lists#edit'
  post 'list/update/:id' => 'lists#update'
  post 'list/create' => 'lists#create'
  get 'list/delete/:id' => 'lists#delete'
  get 'lists/:letter' => 'lists#letter_index'
  get 'lists' => 'lists#index'
  get 'list/:id' => 'lists#show'

  get 'new' => 'recipes#new'
  get 'all' => 'recipes#all'
  get 'search' => 'recipes#search'
  get 'autocomplete' => 'recipes#autocomplete'

  get 'recipes/:letter' => 'recipes#letter_index'
  get 'recipes' => 'recipes#index'
  get 'edit/:id' => 'recipes#edit', as: :edit
  post 'update/:id' => 'recipes#update', as: :update
  post 'create' => 'recipes#create', as: :create
  get 'delete/:id' => 'recipes#delete'
  get ':id' => 'recipes#show', as: :recipe
end
