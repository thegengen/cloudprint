require 'ostruct'
require 'faraday/utils'
require "net/https"
require "uri"

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
module CloudPrint
  class Connection
    def get(path, params = {})
      response = request(:get, path, params)
      parse_response(response)
    end

    def post(path, params = {})
      response = request(:post, path, params)
      parse_response(response)
    end

    private

    def parse_response(response)
      JSON.parse(response.body)
    end

    def request(method, path, params)
      url = full_url_for(path)
      response = make_http_request(:method => method, :url => url, :params => params)
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
                  when :post
                    req = Net::HTTP::Post.new(uri.request_uri)
                    req.set_form_data(options[:params])
                    req
                  else
                    req = Net::HTTP::Get.new(build_get_uri(uri.request_uri, options[:params]))
                end

      set_request_headers(request)
      request
    end

    def set_request_headers(request)
      request['Authorization'] = "OAuth " + CloudPrint.access_token
      request['X-CloudPrint-Proxy'] = 'api-prober'
    end

    def build_get_uri(uri, params = {})
      unescaped_params = params.map { |key,val| "#{key}=#{val}"}.join("&")
      escaped_params = URI.escape(unescaped_params)

      escaped_params = "?#{escaped_params}" unless escaped_params.empty?
      uri + escaped_params
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