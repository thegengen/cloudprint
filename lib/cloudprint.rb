require "rubygems"
require "bundler/setup"
require "oauth2"
require "json"

require "cloudprint/printer"
require "cloudprint/connection"


module CloudPrint
  def self.setup(options = {})
    @refresh_token = options[:refresh_token]
    @client_id = options[:client_id]
    @client_secret = options[:client_secret]
    @callback_url = options[:callback_url]
  end

  def self.client_secret
    @client_secret
  end

  def self.client_id
    @client_id
  end

  def self.refresh_token
    @refresh_token
  end

  def self.callback_url
    @callback_url
  end

  def self.connection
    @connection ||= Connection.new
  end


  def self.access_token
    if access_token_valid?
      get_existing_access_token.token
    else
      get_new_access_token.token
    end
  end

  private

  def self.access_token_valid?
    get_existing_access_token != nil && get_existing_access_token.token && get_existing_access_token.token.strip != "" && !get_existing_access_token.expired?
  end

  def self.get_existing_access_token
    @oauth2_access_token
  end

  def self.get_new_access_token
    @oauth2_access_token = new_oauth2_access_token
    @oauth2_access_token
  end

  def self.oauth_client
    @oauth_client ||= OAuth2::Client.new(CloudPrint.client_id, CloudPrint.client_secret,
                       :authorize_url => "/o/oauth2/auth",
                       :token_url => "/o/oauth2/token",
                       :access_token_url => "/o/oauth2/token",
                       :site => 'https://accounts.google.com/')
  end

  def self.new_oauth2_access_token
    OAuth2::AccessToken.new(oauth_client, "", :refresh_token => CloudPrint.refresh_token).refresh!
  end
end