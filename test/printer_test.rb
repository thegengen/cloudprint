require "helper"
class PrinterTest < Test::Unit::TestCase
  def setup
    # TODO: Is it necessary to pass a fake token to #setup?
    CloudPrint.setup(:refresh_token => 'refresh_token')
  end

  should "initialize a printer" do
    printer = CloudPrint::Printer.new(:id => 'printer_id', :status => 'online', :name => "My Printer")
    assert_equal 'printer_id', printer.id
    assert_equal 'online', printer.status
    assert_equal 'My Printer', printer.name
  end

  should "have tags" do
    printer = CloudPrint::Printer.new(:id => 'printer_id', :status => 'online', :name => "My Printer")
    assert_equal printer.tags, {}

    printer = CloudPrint::Printer.new(:id => 'printer_id', :status => 'online', :name => "My Printer", :tags => {"email" => 'a@b.com'})
    assert_equal printer.tags, {"email" => "a@b.com"}
  end

  should "get a connection when finding a printer by its id" do
    fake_connection.stubs(:get).returns(one_printer_hash)

    CloudPrint.expects(:connection).returns(fake_connection)
    CloudPrint::Printer.find('printer')
  end

  should "call a remote request when finding a printer by its id" do
    fake_connection.expects(:get).returns(one_printer_hash)
    stub_connection
    CloudPrint::Printer.find('printer')
  end

  should "call a remote request with the proper params when finding a printer" do
    fake_connection.expects(:get).with('/printer', :printerid => 'printer', :printer_connection_status => true).returns(one_printer_hash)
    stub_connection
    CloudPrint::Printer.find('printer')
  end

  should "initialize a new object when finding a printer" do
    fake_connection.stubs(:get).returns(one_printer_hash)
    stub_connection
    printer = CloudPrint::Printer.find('my_printer')
    assert_equal 'my_printer', printer.id
    assert_equal 'online', printer.status
    assert_equal 'My Printer', printer.name
    assert_equal printer.tags, {'email' => 'a@b.com' }
  end

  should "initialize an array of printers when finding all printers" do
    fake_connection.stubs(:get).returns(multiple_printer_hash)
    stub_connection
    printers = CloudPrint::Printer.all
    first_printer = printers[0]
    second_printer  = printers[1]
    assert_equal 'first_printer', first_printer.id
    assert_equal 'second_printer', second_printer.id
    assert_equal 'First Printer', first_printer.name
    assert_equal 'Second Printer', second_printer.name
    assert_equal 'First Printer (display name)', first_printer.display_name
    assert_equal 'Second Printer (display name)', second_printer.display_name
    assert_equal 'First printer description', first_printer.description
    assert_equal 'Second printer description', second_printer.description
  end

  should "print stuff" do
    fake_connection.expects(:post).with('/submit', connection_print_params).returns(empty_job)
    stub_connection

    print_stuff
  end

  should "return a job" do
    stub_connection
    fake_connection.stubs(:post).with('/submit', connection_print_params).returns(empty_job)
    job = print_stuff
    assert job.is_a?(CloudPrint::PrintJob)
  end

  should "return nil when the response doesn't have job in it" do
    stub_connection
    fake_connection.stubs(:post).with('/submit', connection_print_params).returns({})
    job = print_stuff

    assert_nil job
  end


  should "print file" do
    fake_connection.expects(:multipart_post).with('/submit', connection_print_file_params).returns(empty_job)
    stub_connection

    print_file
  end

  should "print jobs returning an id and a status" do
    stub_connection
    fake_connection.expects(:post).with('/submit', connection_print_params).returns({"success" => true, "job" => {"id" => "job_id", "status" => 'status'}})
    job = print_stuff

    assert_equal 'job_id', job.id
    assert_equal 'status', job.status
  end

  %w{ONLINE UNKNOWN OFFLINE DORMANT}.each do |status|
    should "recognize a printer as #{status.downcase}" do
      printer = CloudPrint::Printer.new(:connection_status => status)

      assert printer.send(status.downcase + '?')

      %w{ONLINE UNKNOWN OFFLINE DORMANT}.reject{ |s| s == status}.each do |other_statuses|
        assert !printer.send(other_statuses.downcase + '?')
      end
    end
  end

  private

  def empty_job
    {"job" => {}}
  end

  def print_stuff
    printer = CloudPrint::Printer.new(:id => 'printer')
    printer.print(print_params)
  end

  def print_params
     { :title => "Hello World", :content => "<h1>ohai!</h1>", :content_type => "text/html" }
  end

  def connection_print_params
    { :printerid => 'printer', :title => "Hello World", :content => "<h1>ohai!</h1>", :contentType => "text/html" }
  end

  def print_file
    printer = CloudPrint::Printer.new(:id => 'printer')
    printer.print(print_file_params)
  end

  def print_file_params
    { :title => "Ruby!", :content => ruby_png_fixture, :content_type => "image/png" }
  end

  def connection_print_file_params
    { :printerid => 'printer', :title => "Ruby!", :content => ruby_png_fixture, :contentType => "image/png" }
  end

  def one_printer_hash
    {'printers' =>[{'id' => 'my_printer', 'status' => 'online', 'name' => "My Printer", 'displayName' => 'My Printer (display name)', 'tags' => { 'email' => 'a@b.com'}}]}
  end

  def multiple_printer_hash
    {'printers' =>[
        {'id' => 'first_printer',  'status' => 'online', 'name' => "First Printer", 'displayName' => 'First Printer (display name)', 'description' => 'First printer description'},
        {'id' => 'second_printer', 'status' => 'online', 'name' => "Second Printer", 'displayName' => 'Second Printer (display name)', 'description' => 'Second printer description'}
    ]}
  end

  def ruby_png_fixture
    @ruby_png_fixture ||= File.open(fixture_file('ruby.png'))
  end

end
