require 'slim'
require 'cgi'
# require 'faraday'
# require 'json'
# require 'titleize'
require 'stringio'

# PER_PAGE = 10
# TOTAL_PAGES = 10
Home = Struct.new(:query)

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

    def query_ids
      return [] unless request.uri.query
      request.uri.query.split(/\&/).inject([]) do |ids, pair|
        key, value = pair.split(/\=/)
        if key && value && CGI.unescape(key) == 'ids[]'
          ids << CGI.unescape(value)
        end
        ids
      end
    end
  end

  class HomeResource < Resource

    def to_html
      params = CGI::parse(request.uri.query.to_s) || {}
      query = params['q'].first.to_s.strip
      # current_page = params['page'].first.to_i
      # current_page = 1 if current_page < 1
      
      # total_pages = 1
      # links = []
      # if query != ''

      #   # If there's a forward slash, quote it
      #   if query.scan("/").length > 0
      #     query = "\"#{query.gsub(/(^\")|(\")$/, '')}\""
      #   end

      #   base_url = 'http://ec2-54-242-92-147.compute-1.amazonaws.com:8098'
      #   docs_url = 'http://docs.basho.com'

      #   conn = Faraday.new(:url => base_url) do |faraday|
      #     faraday.request  :url_encoded             # form-encode POST params
      #     # faraday.response :logger                  # log requests to STDOUT
      #     faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      #   end

      #   start = (current_page - 1) * PER_PAGE

      #   response = conn.get '/search/riakdoc2', {
      #     wt: 'json',
      #     q: "#{query}",
      #     df: "text_t",
      #     omitHeader: 'true',
      #     hl: 'true',
      #     start: start,
      #     rows: PER_PAGE,
      #     :'hl.fl' => 'text_t',
      #     fl: 'id,_yz_rk,score'
      #   }

      #   reply = JSON.parse(response.body)

      #   highlights = reply['highlighting'] || {}
      #   docs = reply['response']['docs'] || {}
      #   total = reply['response']['numFound'].to_i
      #   total_pages = (total / PER_PAGE).to_i + 1

      #   count = 0
      #   docs.each do |doc|
      #     id = doc['id']
      #     hl = highlights[id]
      #     key = doc['_yz_rk']
      #     title = key.sub(/(\/)$/, '').scan(/[^\/]+$/).first.to_s.gsub(/[\-]/, ' ').titleize
      #     link = docs_url + key
      #     text = (hl['text_t'] || []).first.to_s
      #     text.gsub!(/(\<[^>]+?\>)/) do
      #       (tag = $1) =~ /(\<\/?em\>)/ ? $1 : ''
      #     end
      #     links << {
      #       text: text,
      #       link: link,
      #       title: title
      #     }
      #     count +=1
      #   end
      # end

      home = Home.new(query)
      Slim::Template.new('templates/index.slim', {}).render(home)
    end
  end

  class DialogResource < Resource
    def to_html
      params = CGI::parse(request.uri.query.to_s) || {}
      query = params['q'].first.to_s.strip
      home = Home.new(query)
      Slim::Template.new('templates/dialog.slim', {}).render(home)
    end
  end
end
