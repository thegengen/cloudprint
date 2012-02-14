require "helper"
class PrinterTest < Test::Unit::TestCase
  def setup
    CloudPrint.setup('refresh_token')
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
    title = 'Hello World'
    content = '<h1>ohai!</h1>'
    content_type = 'text/html'
    printer = CloudPrint::Printer.new(:id => 'printer')
    fake_connection.expects(:post).with('/submit', :printerid => 'printer', :title => title, :content => content, :contentType => content_type)
    stub_connection

    printer.print(:title => title, :content => content, :content_type => content_type)
  end

  private

  def one_printer_hash
    {'printers' =>[{'id' => 'my_printer', 'status' => 'online', 'name' => "My Printer"}]}
  end

  def multiple_printer_hash
    {'printers' =>[
        {'id' => 'first_printer',  'status' => 'online', 'name' => "First Printer"},
        {'id' => 'second_printer', 'status' => 'online', 'name' => "Second Printer"}
    ]}
  end

  def fake_connection
    if @connection.nil?
      @connection = mock('connection')
      @connection.stub_everything
    end
    @connection
  end

  def stub_connection
    CloudPrint.stubs(:connection).returns(fake_connection)
  end
end