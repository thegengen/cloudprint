require 'helper'

class AuthTest < Minitest::Test
  def setup
    stub_access_token
    @client = CloudPrint::Client.new(client_id: 'client_1234', client_secret: 'supersecret')
  end

  should 'generate a URI that points to accounts.google.com' do
    assert_match 'accounts.google.com', generated_url
  end

  should 'generate a URI that asks for a code' do
    assert_match 'response_type=code', generated_url
  end

  should 'generate a URI that asks for access to Cloudprint' do
    assert_match '%2Fauth%2Fcloudprint', generated_url
  end

  should 'generate a URI that asks for offline access' do
    assert_match 'access_type=offline', generated_url
  end

  should 'generate a URI that will redirect us to example.com' do
    assert_match 'redirect_uri=http%3A%2F%2Fexample.com', generated_url
  end

  should 'generate a URI that contains the client_id' do
    assert_match 'client_id=client_1234', generated_url
  end

  should 'generate a refresh token when passed in a code' do
    mock_oauth_code = mock('oauth_code')
    mock_oauth_code.stubs(:get_token).returns(mock_refresh_token)

    @client.oauth_client.stubs(auth_code: mock_oauth_code)
    token = @client.auth.generate_token('google_code', "http://example.com")

    assert_equal "random_refresh_token", token
    assert_equal "random_refresh_token", @client.refresh_token
  end

  private

  def generated_url
    @client.auth.generate_url("http://example.com")
  end
end
