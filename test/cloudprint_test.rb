require './helper'

class CloudPrintTest < Minitest::Test
  def setup
    stub_access_token
    @client = new_client
  end

  should "have CloudPrint" do
    assert_nothing_raised { CloudPrint }
  end

  should "be able to set up CloudPrint" do
    assert_nothing_raised do
      CloudPrint::Client.new
    end
   end

  should "stores a client id, client secret, callback URL and refresh token" do
    client = CloudPrint::Client.new(:refresh_token => 'refresh_token', :client_id => 'client_id', :client_secret => 'client_secret', :callback_url => 'callback_url')
    assert_equal 'client_id', client.client_id
    assert_equal 'client_secret', client.client_secret
    assert_equal 'refresh_token', client.refresh_token
    assert_equal 'callback_url', client.callback_url
  end

  should "check if the access token is still valid" do
    @client.expects(:access_token_valid?).returns(true)
    @client.stubs(:renew_access_token!).returns(mock_access_token)
    @client.access_token
  end

  should "get the existing access token use it if it's still valid" do
    token = mock_access_token
    token.expects(:token)

    @client.stubs(:access_token_valid?).returns(true)
    @client.instance_variable_set :@access_token, token
    @client.expects(:renew_access_token!).never
    @client.access_token
  end

  should "get the existing access token get a new one if it's no longer valid" do
    @client.stubs(:access_token_valid?).returns(false)
    @client.expects(:renew_access_token!).returns(mock_access_token)
    @client.access_token
  end

  should "not have a nil access token" do
    @client.instance_variable_set :@access_token, nil
    @client.expects(:renew_access_token!).returns(mock_access_token)
    @client.access_token
  end

  should "not allow a blank string for an access token" do
    @client.instance_variable_set :@access_token, ' '
    @client.expects(:renew_access_token!).returns(mock_access_token)
    @client.access_token
  end

  should "have a string as an access token" do
    @client.stubs(:access_token_valid?).returns(true)
    @client.expects(:renew_access_token!).never
    @client.instance_variable_set :@access_token, mock_access_token
    assert_equal("token", @client.access_token)
  end

  should "initialize an OAuth2 client when getting a new access token" do
    @client.stubs(:access_token_valid?).returns(false)
    @client.expects(:oauth_client)
    @client.access_token
  end

  should "set up an oauth client" do
    client = CloudPrint::Client.new(:client_id => 'client_id', :client_secret => 'client_secret', :callback_url => "http://test.com/callback")
    client.stubs(:access_token_valid?).returns(false)
    OAuth2::Client.expects(:new).with('client_id', 'client_secret',
                                      :authorize_url => "/o/oauth2/auth",
                                      :token_url => "/o/oauth2/token",
                                      :access_token_url => "/o/oauth2/token",
                                      :site => 'https://accounts.google.com/')

    client.access_token
  end

  should "initialize an access token when getting a new access token" do
    client = CloudPrint::Client.new(:refresh_token => "refresh_token")
    client.stubs(:access_token_valid?).returns(false)

    client.expects(:renew_access_token!).returns(mock_access_token)
    client.access_token
  end

  should "get an auth token from oauth2" do
    token = mock_access_token
    @client.stubs(:access_token_valid?).returns(false)
    stub_oauth_client

    OAuth2::AccessToken.expects(:new).with(mock_oauth_client, "", :refresh_token => "refresh_token").returns(token)
    token.expects(:refresh!).returns(mock_access_token)
    @client.access_token
  end

  should "expire if the access token is invalid" do
    token = mock_access_token
    token.stubs(:expired?).returns(true)
    @client.instance_variable_set :@access_token, token
    stub_oauth_client

    @client.expects(:renew_access_token!).returns(token)
    @client.access_token
  end

  should "get a new access token when setting a new refresh token" do
    @client.expects(:renew_access_token!)
    @client.refresh_token = 'new_token'
  end
end
