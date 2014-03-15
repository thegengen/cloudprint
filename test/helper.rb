require 'cloudprint'
require 'test/unit'
require 'shoulda/context'
require 'mocha/test_unit'

class Test::Unit::TestCase

  def new_client
    CloudPrint::Client.new(refresh_token: "refresh_token")
  end
  
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

  def mock_access_token(token = 'token')
    mock = mock('token')
    mock.stubs(:token).returns(token)
    mock.stubs(:expired?).returns(false)
    mock
  end

  def stub_http
    mock = mock_http()
    Net::HTTP.stubs(:new).returns(mock)
  end

  def stub_parsing_responses
    CloudPrint::Connection.any_instance.stubs(:parse_response)
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
    CloudPrint::Client.any_instance.stubs(:oauth_client).returns(mock_oauth_client)
  end

  def fake_connection
    @connection ||= mock('connection')
  end

  def stub_connection
    CloudPrint::Client.any_instance.stubs(:connection).returns(fake_connection)
    @connection.stub_everything
  end

  def fixture_file(filename)
    File.join(File.dirname(__FILE__), 'fixtures', filename)
  end
end
