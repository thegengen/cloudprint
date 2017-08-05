module CloudPrint
  class Error < StandardError; end
  class RequestError < Error; end
  class PrintError < Error; end
end
