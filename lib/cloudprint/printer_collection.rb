module CloudPrint
  class PrinterCollection

    attr_reader :client
    
    def initialize client
      @client = client
    end
    
    def find(printer_id)
      response = client.connection.get('/printer', :printerid => printer_id, :printer_connection_status => true)
      first_printer_hash = response['printers'].first
      new_printer_from_hash(first_printer_hash)
    end

    def all
      search_all
    end

    def search(query = nil, conditions = {})
      conditions[:q] = query unless query.nil?

      response = client.connection.get('/search', conditions)
      response['printers'].map { |p| new_printer_from_hash(p) }
    end

    def method_missing(meth, *args, &block)
      if meth =~ /^search_(#{Printer::CONNECTION_STATUSES.map(&:downcase).join('|')}|all)$/
        search args[0], connection_status: $1.upcase
      else
        super
      end
    end

    def new opts
      Printer.new(opts.merge(client: client))
    end

    def new_printer_from_hash(hash)
      Printer.new(
        client: client,
        id: hash['id'],
        status: hash['status'],
        name: hash['name'],
        display_name: hash['displayName'],
        tags: hash['tags'],
        connection_status: hash['connectionStatus'],
        description: hash['description']
        )
    end
  end
end
