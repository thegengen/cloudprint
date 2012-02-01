require "cloudprint/printer"
require "cloudprint/connection"
module CloudPrint
  def self.setup(token)
    @token = token
  end

  def self.token
    @token
  end

  def self.connection
    @connection ||= Connection.new
  end
end