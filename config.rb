require 'webmachine'
require './lib/resources/home_resource'

# Create an application which encompasses routes and configuration
HomeApp = Webmachine::Application.new do |app|
  app.routes do
    # Point all URIs at the SearchResource class
    add ['*'], HomeResource
  end

  app.configure do |config|
    config.ip = '0.0.0.0'
    config.port = ENV['PORT'] || 3000
    # config.adapter = :Mongrel
  end
end

HomeApp.run
