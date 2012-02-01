require "cloudprint/printer"
module CloudPrint
  def self.setup(token)
    @token = token
  end

  def self.token
    @token
  end
end