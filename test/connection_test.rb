require "helper"

class ConnectionTest < Test::Unit::TestCase
  def setup
    @connection = CloudPrint::Connection.new
  end

  test "Connection class exists" do
    assert_nothing_raised { CloudPrint::Connection }
  end

  test "you can get using a connection" do
    any_connection.stubs(:request)
    @connection.get('/foo')
  end

  test "you can post using a connection" do
    any_connection.stubs(:request)
    @connection.post('/foo')
  end

  test "connections make requests to the right url" do
    stub_http
    @connection.expects(:make_http_request).with(:method => :get, :url => "https://www.google.com/cloudprint/submit", :params => {})
    @connection.get('/submit')
  end

  test "connections build http connections and requests" do
    stub_http
    @connection.stubs(:build_request)

    @connection.expects(:build_http_connection).returns(mock_http)
    @connection.get('/submit')
  end

  test "connections build http request with proper values" do
    stub_http
    @connection.stubs(:build_http_connection).returns(mock_http)

    @connection.expects(:build_request)
    @connection.post('/submit', {:text => "ohai!"})
  end

  test "connections use the access token" do
    stub_http
    @connection.stubs(:build_http_connection).returns(mock_http)

    CloudPrint.expects(:access_token).returns(mock_access_token)
    @connection.get('/submit')
  end
end