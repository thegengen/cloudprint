require "cloudprint"
Bundler.require(:test)

class Test::Unit::TestCase
  def any_connection
    CloudPrint::Connection.any_instance
  end

  def any_access_token
    OAuth2::AccessToken.any_instance
  end

  def stub_access_token
    mock_access_token.stub_everything
    any_access_token.stubs(:refresh!).returns(mock_access_token)
  end

  def mock_access_token
    @mock_access_token ||= mock('access_token')
  end

  def stub_http
    mock = mock_http()

    Net::HTTP.stubs(:new).returns(mock)
  end

  def mock_http
    @mock_http ||= mock('http')
    @mock_http.stub_everything
    @mock_http
  end

  def mock_oauth_client
    @oauth_client ||= mock('oauth_client')
  end

  def stub_oauth_client
    CloudPrint.stubs(:oauth_client).returns(mock_oauth_client)
  end
end