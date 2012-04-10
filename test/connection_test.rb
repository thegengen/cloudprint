require "helper"

class ConnectionTest < Test::Unit::TestCase
  def setup
    @connection = CloudPrint::Connection.new
  end

  should "get using a connection" do
    stub
    any_connection.stubs(:request)
    @connection.get('/foo')
  end

  should "post using a connection" do
    stub
    any_connection.stubs(:request)
    @connection.post('/foo')
  end

  should "post multipart data using a connection" do
    stub
    any_connection.stubs(:request)
    @connection.multipart_post('/foo')
  end

  should "make requests to the right url with POST" do
    stub
    @connection.expects(:make_http_request).with(:method => :post, :url => "https://www.google.com/cloudprint/submit", :params => {})
    @connection.post('/submit')
  end

  should "build http connections and requests" do
    stub
    @connection.stubs(:build_request)

    @connection.expects(:build_http_connection).returns(mock_http)
    @connection.post('/submit')
  end

  should "build http request with proper values" do
    stub
    @connection.stubs(:build_http_connection).returns(mock_http)

    @connection.expects(:build_request)
    @connection.post('/submit', {:text => "ohai!"})
  end

  should "build a URL when parameters are used" do
    stub
    @connection.stubs(:build_http_connection).returns(mock_http)

    params = { :text => 'ohai' }
    @connection.expects(:build_get_uri).returns("https://www.google.com/cloudprint/submit")
    @connection.get('/submit', params)
  end

  should "get from the correct URL when params are used" do
    stub

    params = { :text => 'ohai world' }
    Net::HTTP::Get.expects(:new).with("/cloudprint/submit?text=ohai%20world").returns(mock_http)
    @connection.get('/submit', params)
  end

  should "use the access token" do
    stub
    @connection.stubs(:build_http_connection).returns(mock_http)

    CloudPrint.expects(:access_token).returns('token')
    @connection.get('/submit')
  end

  should "parse the response" do
    stub
    @connection.expects(:parse_response)
    @connection.get('/submit')
  end

  should "parse the response as JSON" do
    stub(:parsing_responses => false)
    response = mock('response')
    response.stubs(:body).returns('')
    @connection.stubs(:make_http_request).returns(response)

    JSON.expects(:parse)
    @connection.get('/submit')
  end

  should "setup form properly on multipart POSTs" do
    stub

    file = mock('File')
    Net::HTTP::Post.any_instance.expects(:set_form).with({'contentType' => 'application/pdf', 'content' => file}, 'multipart/form-data')
    @connection.multipart_post('/submit', { :contentType => 'application/pdf', :content => file })
  end

  private

  def stub(options = {})
    options = {:http => true, :parsing_responses => true}.merge(options)

    stub_http if options[:http]
    stub_parsing_responses if options[:parsing_responses]
  end
end
