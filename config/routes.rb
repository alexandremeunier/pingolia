Rails.application.routes.draw do
  scope module: 'api/v1', path: 'api/1' do 
    resources :pings, only: :create do 
      get ':origin/hours', action: :hours, as: :hours, on: :collection
      get ':origin/months', action: :months, as: :months, on: :collection
      get ':origin/years', action: :years, as: :years, on: :collection
    end
  end

  root 'home#index'
end
