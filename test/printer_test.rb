require "helper"
class PrinterTest < Test::Unit::TestCase
  def setup
    CloudPrint.setup('refresh_token')
  end

  test "CloudPrint Printers exist" do
    assert_nothing_raised { CloudPrint::Printer }
  end

  test "should find a printer by its id" do
    stub_connection
    assert_nothing_raised { CloudPrint::Printer.find('test') }
  end

  test "finding a printer by its id should get a connection" do
    CloudPrint.expects(:connection).returns(fake_connection)
    CloudPrint::Printer.find('printer')
  end

  test "finding a printer by its id should call a remote request" do
    fake_connection.expects(:post)
    stub_connection
    CloudPrint::Printer.find('printer')
  end

  test "finding a printer should call a remote request with the proper params" do
    fake_connection.expects(:post).with('/printer', :printer_id => 'printer')
    stub_connection
    CloudPrint::Printer.find('printer')
  end

  private

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