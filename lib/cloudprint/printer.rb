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
      method = is_multipart?(content) ? :multipart_post : :post
      params = {
        printerid: id,
        title: options[:title],
        content: content,
        contentType: options[:content_type]
      }
      params[:ticket] = options[:ticket].to_json if options[:ticket] && options[:ticket] != ''
      response = client.connection.send(method, '/submit', params)

      raise PrintError, unknown_erorr_message if response.nil?
      raise PrintError, response["message"] || unknown_erorr_message if response["job"].nil?

      client.print_jobs.new_from_response response["job"]
    end

    def method_missing(meth, *args, &block)
      if CONNECTION_STATUSES.map{ |s| s.downcase + '?' }.include?(meth.to_s)
        connection_status.downcase == meth.to_s.chop
      else
        super
      end
    end

    private

    def is_multipart?(content)
      content.is_a?(IO) || content.is_a?(StringIO) || content.is_a?(Tempfile)
    end

    def unknown_erorr_message
      'An unknown print error has occurred. '\
      'Please check Google CloudPrint for errors.'
    end
  end
end
