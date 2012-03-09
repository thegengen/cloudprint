require "helper"
class PrinterTest < Test::Unit::TestCase
  def setup
    # TODO: Is it necessary to pass a fake token to #setup?
    CloudPrint.setup(:refresh_token => 'refresh_token')
  end

  test "CloudPrint Printers exist" do
    assert_nothing_raised { CloudPrint::Printer }
  end

  test "initializing a printer" do
    printer = CloudPrint::Printer.new(:id => 'printer_id', :status => 'online', :name => "My Printer")
    assert_equal 'printer_id', printer.id
    assert_equal 'online', printer.status
    assert_equal 'My Printer', printer.name
  end

  test "a printer has tags" do
    printer = CloudPrint::Printer.new(:id => 'printer_id', :status => 'online', :name => "My Printer")
    assert_equal printer.tags, {}

    printer = CloudPrint::Printer.new(:id => 'printer_id', :status => 'online', :name => "My Printer", :tags => {"email" => 'a@b.com'})
    assert_equal printer.tags, {"email" => "a@b.com"}
  end

  test "finding a printer by its id should get a connection" do
    fake_connection.stubs(:get).returns(one_printer_hash)

    CloudPrint.expects(:connection).returns(fake_connection)
    CloudPrint::Printer.find('printer')
  end

  test "finding a printer by its id should call a remote request" do
    fake_connection.expects(:get).returns(one_printer_hash)
    stub_connection
    CloudPrint::Printer.find('printer')
  end

  test "finding a printer should call a remote request with the proper params" do
    fake_connection.expects(:get).with('/printer', :printerid => 'printer').returns(one_printer_hash)
    stub_connection
    CloudPrint::Printer.find('printer')
  end

  test "finding a printer should initialize a new object" do
    fake_connection.stubs(:get).returns(one_printer_hash)
    stub_connection
    printer = CloudPrint::Printer.find('my_printer')
    assert_equal 'my_printer', printer.id
    assert_equal 'online', printer.status
    assert_equal 'My Printer', printer.name
    assert_equal printer.tags, {'email' => 'a@b.com' }
  end

  test "finding all printer should initialize an array of printers" do
    fake_connection.stubs(:get).returns(multiple_printer_hash)
    stub_connection
    printers = CloudPrint::Printer.all
    first_printer = printers[0]
    second_printer  = printers[1]
    assert_equal 'first_printer', first_printer.id
    assert_equal 'second_printer', second_printer.id
    assert_equal 'First Printer', first_printer.name
    assert_equal 'Second Printer', second_printer.name
  end

  test "print stuff" do
    fake_connection.expects(:post).with('/submit', connection_print_params).returns(empty_job)
    stub_connection

    print_stuff
  end

  test "print stuff returns a job" do
    stub_connection
    fake_connection.stubs(:post).with('/submit', connection_print_params).returns(empty_job)
    job = print_stuff
    assert job.is_a?(CloudPrint::PrintJob)
  end

  test "print file" do
    fake_connection.expects(:multipart_post).with('/submit', connection_print_file_params).returns(empty_job)
    stub_connection

    print_file
  end

  test "print job has an id and a status" do
    stub_connection
    fake_connection.expects(:post).with('/submit', connection_print_params).returns({"success" => true, "job" => {"id" => "job_id", "status" => 'status'}})
    job = print_stuff

    assert_equal 'job_id', job.id
    assert_equal 'status', job.status
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
    {'printers' =>[{'id' => 'my_printer', 'status' => 'online', 'name' => "My Printer", 'tags' => { 'email' => 'a@b.com'}}]}
  end

  def multiple_printer_hash
    {'printers' =>[
        {'id' => 'first_printer',  'status' => 'online', 'name' => "First Printer"},
        {'id' => 'second_printer', 'status' => 'online', 'name' => "Second Printer"}
    ]}
  end

  def ruby_png_fixture
    @ruby_png_fixture ||= File.open(fixture_file('ruby.png'))
  end

end
