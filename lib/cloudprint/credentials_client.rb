require "net/http"
require "uri"

module CloudPrint
  class CredentialsClient
    attr_reader :connection
    attr_reader :printers
    attr_reader :print_jobs

    def initialize(email, password)
      @email = email
      @password = password

      @connection = Connection.new(self)
      @printers = PrinterCollection.new(self)
      @print_jobs = PrintJobCollection.new(self)
    end

    def authtoken
      @authtoken ||= get_auth_token
    end

    def auth_header
      "GoogleLogin auth=#{authtoken}"
    end

    private

    def auth_regex
      /Auth=([a-z0-9_-]+)/i
    end

    def get_auth_token
      http = Net::HTTP.new("www.google.com", 443)
      http.use_ssl = true

      request = Net::HTTP::Post.new("/accounts/ClientLogin")
      request.set_form_data({
        "accountType" => "HOSTED_OR_GOOGLE",
        "Email" => @email,
        "Passwd" => @password,
        "service" => "cloudprint",
        "source" => "GCP"
      })
      response = http.request(request)
      auth_regex.match(response.body).captures.first
    end

  end
end
