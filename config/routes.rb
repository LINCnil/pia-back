Rails.application.routes.draw do
  resources :pias do
    member do
      post '/duplicate', to: 'pias#duplicate'
    end
    collection do
      post '/import', to: 'pias#import'
    end
  end
  resources :answers
  resources :comments
  resources :evaluations
  resources :measures
  resources :attachments
end
