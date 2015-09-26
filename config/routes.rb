Rails.application.routes.draw do
  scope module: 'api/v1', path: 'api/1' do 
    resources :pings, only: :create do 
      get ':origin/hours', action: :hours, as: :hours, on: :collection
      get ':origin/months', action: :months, as: :months, on: :collection
      get ':origin/days', action: :days, as: :days, on: :collection
    end
  end

  root 'home#index'

  if Rails.env.development?
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
end
