Rails.application.routes.draw do
  resources :pias do
    member do
      post '/duplicate', to: 'pias#duplicate'
      resources :answers
      resources :comments
      resources :evaluations
      resources :measures
      resources :attachments
    end
    collection do
      post '/import', to: 'pias#import'
    end
  end
end
