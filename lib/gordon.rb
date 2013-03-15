require 'webmachine/adapters/rack'

module Gordon; end

require 'gordon/hstore'
require 'gordon/records'
require 'gordon/serializers'
# require 'gordon/contexts'
require 'gordon/resources'
require 'gordon/bootstrap'

module Gordon
  Application = Webmachine::Application.new do |app|
    app.configure do |config|
      config.adapter = :Rack
    end

    app.routes do
      # Point all URIs at the HomeResource class
      add ['dialog.html'], DialogResource
      add ['form.html'], FormResource
      add ['*'], HomeResource
    end

  end

  VERSION_REGEX = /\d+\.\d+\.\d+\w*/

  def self.version(version_string)
    strict = normalize_version(version_string)
    strict.blank? ? version_string : strict
  end

  def self.normalize_version(version_string)
    version_string[VERSION_REGEX, 0]
  end
end
