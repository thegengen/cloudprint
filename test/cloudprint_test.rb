require 'helper'

class CloudPrintTest < Test::Unit::TestCase
  def setup
    stub_access_token
  end

  should "have CloudPrint" do
    assert_nothing_raised { CloudPrint }
  end

  should "be able to set up CloudPrint" do
    assert CloudPrint.respond_to?(:setup)
  end

  should "stores a client id, client secret, callback URL and refresh token" do
    CloudPrint.setup(:refresh_token => 'refresh_token', :client_id => 'client_id', :client_secret => 'client_secret', :callback_url => 'callback_url')
    assert_equal 'client_id', CloudPrint.client_id
    assert_equal 'client_secret', CloudPrint.client_secret
    assert_equal 'refresh_token', CloudPrint.refresh_token
    assert_equal 'callback_url', CloudPrint.callback_url
  end

  should "check if the access token is still valid" do
    CloudPrint.expects(:access_token_valid?).returns(true)
    CloudPrint.stubs(:get_existing_access_token).returns(mock_access_token)
    CloudPrint.access_token
  end

  should "get the existing access token use it if it's still valid" do
    token = mock_access_token
    token.expects(:token)

    CloudPrint.stubs(:access_token_valid?).returns(true)
    CloudPrint.expects(:get_existing_access_token).once.returns(token)
    CloudPrint.expects(:get_new_access_token).never
    CloudPrint.access_token
  end

  should "get the existing access token get a new one if it's no longer valid" do
    CloudPrint.stubs(:access_token_valid?).returns(false)
    CloudPrint.expects(:get_new_access_token).returns(mock_access_token)
    CloudPrint.access_token
  end

  should "not set a nil access token" do
    CloudPrint.expects(:get_existing_access_token).returns(nil)
    CloudPrint.expects(:get_new_access_token).returns(mock_access_token)
    CloudPrint.access_token
  end

  should "not have a nil access token" do
    CloudPrint.expects(:get_existing_access_token).at_least_once.returns(mock_access_token(nil))
    CloudPrint.expects(:get_new_access_token).returns(mock_access_token)
    CloudPrint.access_token
  end

  should "not allow a blank string for an access token" do
    CloudPrint.expects(:get_existing_access_token).at_least_once.returns(mock_access_token(' '))
    CloudPrint.expects(:get_new_access_token).returns(mock_access_token)
    CloudPrint.access_token
  end

  should "have a string as an access token" do
    CloudPrint.stubs(:access_token_valid?).returns(true)
    CloudPrint.expects(:get_new_access_token).never
    CloudPrint.expects(:get_existing_access_token).at_least_once.returns(mock_access_token)
    assert_equal("token", CloudPrint.access_token)
  end

  should "initialize an OAuth2 client when getting a new access token" do
    CloudPrint.stubs(:access_token_valid?).returns(false)
    CloudPrint.expects(:oauth_client)
    CloudPrint.access_token
  end

  should "set up an oauth client" do
    CloudPrint.setup(:client_id => 'client_id', :client_secret => 'client_secret', :callback_url => "http://test.com/callback")
    CloudPrint.stubs(:access_token_valid?).returns(false)
    OAuth2::Client.expects(:new).with('client_id', 'client_secret',
                                      :authorize_url => "/o/oauth2/auth",
                                      :token_url => "/o/oauth2/token",
                                      :access_token_url => "/o/oauth2/token",
                                      :site => 'https://accounts.google.com/')

    CloudPrint.access_token
  end

  should "initialize an access token when getting a new access token" do
    CloudPrint.setup(:refresh_token => "refresh_token")
    CloudPrint.stubs(:access_token_valid?).returns(false)

    CloudPrint.expects(:new_oauth2_access_token).returns(mock_access_token)
    CloudPrint.access_token
  end

  should "get an auth token from oauth2" do
    token = mock_access_token
    CloudPrint.setup(:refresh_token => "refresh_token")
    CloudPrint.stubs(:access_token_valid?).returns(false)
    stub_oauth_client

    OAuth2::AccessToken.expects(:new).with(mock_oauth_client, "", :refresh_token => "refresh_token").returns(token)
    token.expects(:refresh!).returns(mock_access_token)
    CloudPrint.access_token
  end

  should "expire if the access token is invalid" do
    token = mock_access_token
    token.stubs(:expired?).returns(true)
    CloudPrint.stubs(:get_existing_access_token).returns()
    stub_oauth_client

    CloudPrint.expects(:get_new_access_token).returns(token)
    CloudPrint.access_token
  end

  should "get a new access token when setting a new refresh token" do
    CloudPrint.expects(:get_new_access_token)
    CloudPrint.refresh_token = 'new_token'
  end
end
