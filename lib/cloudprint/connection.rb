require 'ostruct'
require "net/https"
require "uri"

module CloudPrint
  class Connection

    def initialize client
      @client = client
    end

    def get(path, params = {})
      response = request(:get, path, params)
      parse_response(response)
    end

    def post(path, params = {})
      response = request(:post, path, params)
      parse_response(response)
    end

    def multipart_post(path, params = {})
      response = request(:multipart, path, params)
      parse_response(response)
    end

    private

    def parse_response(response)
      begin
        JSON.parse(response.body)
      rescue => e
        puts response.body
        raise e
      end
    end

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
                  when :multipart
                    req = Net::HTTP::Post.new(uri.request_uri)
                    # Convert hash keys to strings, because that's what Net::HTTPGenericRequest#encode_multipart_form_data assumes they are
                    req.set_form(options[:params].inject({}) {|memo, (k,v)| memo[k.to_s] = v; memo }, 'multipart/form-data')
                    req
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
      request['Authorization'] = "OAuth " + @client.access_token
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
