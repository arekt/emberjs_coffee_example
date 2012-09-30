class ApplicationController < ActionController::Base
  protect_from_forgery
  if Rails.env.production?
    http_basic_authenticate_with :name => ENV['APP_USER'] || 'afs234aa', :password =>  ENV['APP_PASSWORD'] || '234fsd234rq2da'
    force_ssl
  end 
end
