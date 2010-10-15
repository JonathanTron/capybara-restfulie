require 'restfulie'

class Capybara::Driver::Restfulie < Capybara::Driver::Base
  class Node < Capybara::Driver::RackTest::Node
  end

  attr_accessor :as, :follow
  attr_reader :app, :rack_server, :options, :response, :parsed_response
  
  def client
    unless @client
      @client = Object.new.send(:extend, Restfulie::Client::EntryPoint)
    end
    @client
  end
  
  def initialize(app, options={})
    @app = app
    @options = options
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot if Capybara.run_server
    Restfulie::Common::Logger.logger = Logger.new("/dev/null")
  end

  def visit(url, params = {})
    reset_cache
    process :get, url, params
  end
  
  def get(url, params = {}, headers = {})
    reset_cache
    process :get, url, params, headers
  end

  def post(url, params = {}, headers = {})
    reset_cache
    process :post, url, params, headers
  end

  def put(url, params = {}, headers = {})
    reset_cache
    process :put, url, params, headers
  end

  def delete(url, params = {}, headers = {})
    reset_cache
    process :delete, url, params, headers
  end

  def head(url, params = {}, headers = {})
    reset_cache
    process :head, url, params, headers
  end

  def patch(url, params = {}, headers = {})
    reset_cache
    process :patch, url, params, headers
  end

  def request(url, params = {}, headers = {})
    reset_cache
    process :request, url, params, headers
  end
  
  def submit(method, path, attributes)
    path = request.path if not path or path.empty?
    process method.to_sym, path, attributes
  end

  def find(selector)
    case response.headers["content-type"]
    when "application/xml", "text/xml"
      xml.xpath(selector).map { |node| Node.new(self, node) }
    when "text/html"
      html.xpath(selector).map { |node| Node.new(self, node) }
    else
      raise "Content-Type: #{response.headers["content-type"]} is not handling xpath search"
    end
  end
  
  def html
    @html ||= Nokogiri::HTML(body)
  end
  def xml
    @xml ||= Nokogiri::XML(body)
  end
  
  def body
    response.body
  end
  alias_method :source, :body
  
  def response_headers
    response.headers
  end

  def status_code
    response.code
  end
  
  def current_url
    @current_uri.to_s
  end
  
  def reset!
    @client = nil
    @response = nil
    @parsed_response = nil
    @current_uri = nil
    reset_cache
  end
  
  def as
    @as ||= "application/json"
  end
  
  def with
    @with ||= {}
  end

  def process(method, path, params = {}, headers = {})
    res = client.at url(path)          # URL to query based on the app host/port
    res = res.as as                    # Accept/Content-Type setting
    res = res.with with.merge(headers) # Pass headers to be merged with existing ones
    res = res.follow                   # Activate follow of redirection
    res = if [:delete, :head].include?(method.to_sym)
      res.send method
    else
      res.send method, params
    end

    if res.respond_to?(:response)
      @current_uri = url(path)
      @response = res.response
      @parsed_response = res
    else
      @current_uri = res.first.first
      @response = res.last
      @parsed_response = nil
    end
  end

private

  def reset_cache
    @xml = nil
    @html = nil
  end

  def url(path)
    rack_server.url(path)
  end
  
end