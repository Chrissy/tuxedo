# frozen_string_literal: true

Tuxno2::Application.routes.draw do
  devise_for :users

  root 'indeces#home'

  get 'admin' => 'indeces#admin'
  get 'about' => 'indeces#about'
  get 'index/:letter' => 'indeces#letter_index'
  get 'index' => 'indeces#index'
  get 'index/more/:page' => 'indeces#more'
  get 'image-upload-token' => 'application#token'

  get 'ingredients/all' => 'components#all'
  get 'ingredients/new' => 'components#new'
  get 'ingredients/edit/:id' => 'components#edit'
  post 'ingredients/update/:id' => 'components#update'
  post 'ingredients/create' => 'components#create'
  get 'ingredients/delete/:id' => 'components#delete'
  get 'ingredients/:id/recents/:page' => 'components#recents'
  get 'ingredients/:id' => 'components#show'
  get 'ingredients-index/:letter' => 'components#letter_index'
  get 'ingredients' => 'components#index'

  # redirects for deprecated list pages
  get '/list/chartreuse-cocktail-recipes', to: redirect('/ingredients/chartreuse-cocktail-recipes')
  get '/list/holiday-cocktails-cocktail-recipes', to: redirect('/ingredients/chartreuse-cocktail-recipes')
  get '/list/tequila-cocktail-recipes-162045e6-2cfb-4e15-b67b-55abc1899bd7', to: redirect('/ingredients/chartreuse-cocktail-recipes')
  get '/list/whiskey-cocktails-cocktail-recipes', to: redirect('/ingredients/chartreuse-cocktail-recipes')
  get '/list/fall-cocktails-cocktail-recipes', to: redirect('/tags/fall')
  get 'list/rum-cocktail-recipes', to: redirect('/ingredients/rum-cocktail-recipes')
  get 'list/rum-cocktails-cocktail-recipes', to: redirect('/ingredients/rum-cocktail-recipes')

  get 'tags/:tag' => 'recipes#tag'
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
