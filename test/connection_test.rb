require "helper"

class ConnectionTest < Test::Unit::TestCase
  test "Connection class exists" do
    assert_nothing_raised { CloudPrint::Connection }
  end
end