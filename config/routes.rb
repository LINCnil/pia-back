Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :pias
  resources :answers
  resources :comments
  resources :evaluations
  resources :measures
  resources :attachments

  # Non CRUD routes
  post '/pias/duplicate/:id', to: 'pias#duplicate'
  post '/pias/import', to: 'pias#import'
end
