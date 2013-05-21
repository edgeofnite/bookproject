BooksNew::Application.routes.draw do

  # This line mounts Forem's routes at /forums by default.
  # This means, any requests to the /forums URL of your application will go to Forem::ForumsController#index.
  # If you would like to change where this extension is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Forem relies on it being the default of "forem"
  mount Forem::Engine, :at => '/forums'


  #resources :users

  root :to => 'main#index'
  match ':controller/:action/:id'
  match ':controller/:action'
  #get '/users/sign_in', :to => "login#login"

  #map.resources :sessions, :users => {:recovery => :get}
  #map.resources :users, :collection => {:help => :get, :recover => :post}
  resources :users 
  resources :chapters
  resources :books

  # See how all your routes lay out with "rake routes"
end
