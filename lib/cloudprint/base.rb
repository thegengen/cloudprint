module CloudPrint
  class Base
    attr_reader :client_secret
    attr_reader :client_id
    attr_reader :refresh_token
    attr_reader :callback_url
    attr_reader :connection
    attr_reader :printers
    attr_reader :print_jobs
    
    def initialize(options = {})
      @refresh_token = options[:refresh_token]
      @client_id = options[:client_id]
      @client_secret = options[:client_secret]
      @callback_url = options[:callback_url]
      @connection = Connection.new(self)
      @printers = PrinterCollection.new(self)
      @print_jobs = PrintJobCollection.new(self)
    end
    
    def access_token
      (access_token_valid? && @access_token || renew_access_token!).token
    end

    def refresh_token=(new_token)
      @refresh_token = new_token
      renew_access_token!
    end

    def access_token_valid?
      @access_token.present? && @access_token.token.present? && !@access_token.expired?
    end

    private

    def renew_access_token!
      @access_token = OAuth2::AccessToken.new(oauth_client, "", :refresh_token => refresh_token).refresh!
    end

    def oauth_client
      @oauth_client ||= OAuth2::Client.new(client_id, client_secret,
        :authorize_url => "/o/oauth2/auth",
        :token_url => "/o/oauth2/token",
        :access_token_url => "/o/oauth2/token",
        :site => 'https://accounts.google.com/')
    end
  end
end
