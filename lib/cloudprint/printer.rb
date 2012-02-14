module CloudPrint
  class Printer
    attr_reader :id, :status, :name
    def initialize(options = {})
      @id = options[:id]
      @status = options[:status]
      @name = options[:name]
    end

    def print(options)
      CloudPrint.connection.post('/submit', :printerid => self.id, :title => options[:title], :content => options[:content], :contentType => options[:content_type])
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
        Printer.new(:id => hash['id'], :status => hash['status'], :name => hash['name'])
      end
    end
  end
end