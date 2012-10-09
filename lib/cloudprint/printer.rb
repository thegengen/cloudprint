module CloudPrint
  class Printer
    attr_reader :id, :status, :name, :tags, :display_name
    def initialize(options = {})
      @id = options[:id]
      @status = options[:status]
      @name = options[:name]
      @display_name = options[:display_name]
      @tags = options[:tags] || {}
    end

    def print(options)
      method = options[:content].is_a?(IO) ? :multipart_post : :post
      response = CloudPrint.connection.send(method, '/submit', :printerid => self.id, :title => options[:title], :content => options[:content], :contentType => options[:content_type]) || {}
      return nil if response.nil? || response["job"].nil?
      CloudPrint::PrintJob._new_from_response response["job"]
    end

    class << self
      def find(printer_id)
        response = CloudPrint.connection.get('/printer', :printerid => printer_id)
        first_printer_hash = response['printers'].first
        new_from_hash(first_printer_hash)
      end

      def all
        response = CloudPrint.connection.get('/search')
        response['printers'].map { |p| new_from_hash(p) }
      end

      private

      def new_from_hash(hash)
        Printer.new(:id => hash['id'], :status => hash['status'], :name => hash['name'], :display_name => hash['displayName'], :tags => hash['tags'])
      end
    end
  end
end
