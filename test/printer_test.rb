require "test/unit"
require "cloudprint"
class PrinterTest < Test::Unit::TestCase
  test "CloudPrint Printers exist" do
    assert_nothing_raised { CloudPrint::Printer }
  end
end