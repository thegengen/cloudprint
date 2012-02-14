require 'ostruct'
require 'faraday/utils'
require "net/https"
require "uri"

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
module CloudPrint
  class Connection
    def get(path, options = {})
      request(:get, path, options)
    end

    def post(path, options = {})
      request(:post, path, options)
    end

    private

    def request(method, path, params)
      url = full_url_for(path)
      make_http_request(:method => method, :url => url, :params => params)
    end

    def make_http_request(options = {})
      method = options[:method]
      uri = URI.parse(options[:url])
      http = build_http_connection(uri)
      request = build_request(:method => method, :uri => uri, :params => options[:params])

      http.request(request)
    end

    def build_request(options)
      method = options[:method]
      uri = options[:uri]

      request = case method
                  when :get
                    Net::HTTP::Get.new(uri.request_uri)
                  when :post
                    Net::HTTP::Post.new(uri.request_uri)
                  else
                    Net::HTTP::Get.new(uri.request_uri)
                end

      set_request_headers(request)
      request.set_form_data(options[:params]) if method == :post
      request
    end

    def set_request_headers(request)
      request['Authorization'] = "OAuth " + CloudPrint.access_token.token
      request['X-CloudPrint-Proxy'] = 'api-prober'
    end

    def build_http_connection(uri)
      http = Net::HTTP.new(uri.host, uri.port)

      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http
    end

    def full_url_for(path)
      "https://www.google.com/cloudprint" + path
    end
  end
end