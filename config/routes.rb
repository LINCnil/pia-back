Rails.application.routes.draw do
  resources :pias do
    post '/duplicate', to: 'pias#duplicate'
    resources :answers
    resources :comments
    resources :evaluations
    resources :measures
    resources :attachments do
      collection do
        get '/signed', to: 'attachments#signed'
      end
    end
    collection do
      post '/import', to: 'pias#import'
    end
  end
end
