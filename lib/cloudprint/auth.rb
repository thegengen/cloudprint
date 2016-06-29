require "uri"

module CloudPrint
  class Auth
    def initialize(client, options = {})
      @client = client
      @access_type = options[:access_type] || 'offline'
    end

    def generate_url(redirect_uri)
      URI::HTTPS.build(
        host: 'accounts.google.com',
        path: '/o/oauth2/v2/auth',
        query: URI.encode_www_form(url_params(redirect_uri))
      ).to_s
    end

    def generate_token(code, redirect_uri)
      full_token = @client.oauth_client.auth_code.get_token(code, redirect_uri: redirect_uri)
      @client.refresh_token = full_token.refresh_token
    end

    private

    def url_params(redirect_uri)
      {
        response_type: 'code',
        scope: 'https://www.googleapis.com/auth/cloudprint',
        client_id: @client.client_id,
        access_type: @access_type,
        redirect_uri: redirect_uri
      }
    end
  end
end
