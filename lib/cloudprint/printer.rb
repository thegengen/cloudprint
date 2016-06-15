module CloudPrint
  class Printer
    CONNECTION_STATUSES = %w{ONLINE UNKNOWN OFFLINE DORMANT}
    CONFIG_OPTS = [:id, :status, :name, :tags, :display_name, :client, :connection_status, :description, :capabilities]

    CONFIG_OPTS.each { |opt| attr_reader(opt) }

    def initialize(options = {})
      @client = options[:client]
      @id = options[:id]
      @status = options[:status]
      @name = options[:name]
      @display_name = options[:display_name]
      @tags = options[:tags] || {}
      @connection_status = options[:connection_status] || 'UNKNOWN'
      @description = options[:description]
      @capabilities = options[:capabilities]
    end

    def print(options)
      content = options[:content]
      method = content.is_a?(IO) || content.is_a?(StringIO) || content.is_a?(Tempfile) ? :multipart_post : :post
      response = client.connection.send(method, '/submit', :printerid => self.id, :title => options[:title], :content => options[:content], :ticket => options[:ticket].to_json, :contentType => options[:content_type]) || {}
      return nil if response.nil? || response["job"].nil?
      client.print_jobs.new_from_response response["job"]
    end

    def all_jobs
      response = client.connection.post('/jobs', :printerid => self.id)
      return [] if response['jobs'].nil?
      response['jobs'].map { |j| PrintJob.new_from_response(client, j)}
    end

    def method_missing(meth, *args, &block)
      if CONNECTION_STATUSES.map{ |s| s.downcase + '?' }.include?(meth.to_s)
        connection_status.downcase == meth.to_s.chop
      else
        super
      end
    end
  end
end
