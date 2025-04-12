# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  post '/receipts/process', to: 'receipts#create', defaults: { format: :json }
  get '/receipts/:id/points', to: 'receipts#show', defaults: { format: :json }
end
