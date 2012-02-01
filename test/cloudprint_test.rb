require "test/unit"
require "cloudprint"

class CloudPrintTest < Test::Unit::TestCase
  test "CloudPrint exists" do
    assert_nothing_raised { CloudPrint }
  end

  test "CloudPrint can be set up" do
    assert CloudPrint.respond_to?(:setup)
  end

  test "CloudPrint setup stores an API token" do
    CloudPrint.setup('token')
    assert_equal 'token', CloudPrint.token
  end
end