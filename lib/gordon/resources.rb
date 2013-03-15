require 'slim'
# require 'cgi'
require 'ostruct'
# require 'stringio'

# PER_PAGE = 10
# TOTAL_PAGES = 10

module Gordon
  class Resource < Webmachine::Resource
    include Webmachine::Resource::Authentication

    def encodings_provided
      { 'gzip' => :encode_gzip,
        'deflate' => :encode_deflate,
        'identity' => :encode_identity }
    end

    def is_authorized?(auth)
      return true unless %W{PUT POST DELETE}.include?(request.method)
      basic_auth(auth, "GiddyUp") do |user, pass|
        user == AUTH_USER && pass == AUTH_PASSWORD
      end
    end

    def content_types_provided
      [['text/html', :to_html],
       ['application/json', :to_json]]
    end

    def finish_request
      # See seancribbs/webmachine-ruby#68
      unless [204, 205, 304].include?(response.code)
        response.headers['Content-Type'] ||= "text/html"
      end
    end

    # def query_ids
    #   return [] unless request.uri.query
    #   request.uri.query.split(/\&/).inject([]) do |ids, pair|
    #     key, value = pair.split(/\=/)
    #     if key && value && CGI.unescape(key) == 'ids[]'
    #       ids << CGI.unescape(value)
    #     end
    #     ids
    #   end
    # end

    BlankStruct = OpenStruct.new.freeze

    def layout(template, data={})
      data ||= BlankStruct
      @layout ||= Slim::Template.new('templates/_layout.slim', {})
      content = Slim::Template.new("templates/#{template.to_s}.slim", {}).render(data)
      @layout.render{ content }
    end

    def page(template, contentData=nil, pageData=nil)
      contentData ||= BlankStruct
      pageData ||= BlankStruct
      @layout ||= Slim::Template.new('templates/_layout.slim', {})
      @page ||= Slim::Template.new('templates/_page.slim', {})
      content = Slim::Template.new("templates/#{template.to_s}.slim", {}).render(contentData)
      @layout.render{ @page.render(pageData){ content } }
    end
  end

  Home = Struct.new(:query)
  class HomeResource < Resource
    def to_html
      params = CGI::parse(request.uri.query.to_s) || {}
      query = params['q'].first.to_s.strip
      home = Home.new(query)
      page :index, home, OpenStruct.new(home:true)
    end
  end

  class FormResource < Resource
    def to_html
      page :form, nil, OpenStruct.new(title:'Form Header')
    end
  end

  class DialogResource < Resource
    def to_html
      params = CGI::parse(request.uri.query.to_s) || {}
      query = params['q'].first.to_s.strip
      layout :dialog
    end
  end
end
