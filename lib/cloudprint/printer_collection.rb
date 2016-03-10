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
      search()
    end

    def search(query = nil, conditions = {})
      conditions[:q] = query unless query.nil?

      response = client.connection.get('/search', conditions)
      response['printers'].map { |p| new_printer_from_hash(p) }
    end
    alias_method :search_all, :search

    def search_online(q = nil, conditions = {})
      search_with_status(q, 'ONLINE', conditions)
    end

    def search_unknown(q = nil, conditions = {})
      search_with_status(q, 'UNKNOWN', conditions)
    end

    def search_offline(q = nil, conditions = {})
      search_with_status(q, 'OFFLINE', conditions)
    end

    def search_dormant(q = nil, conditions = {})
      search_with_status(q, 'DORMANT', conditions)
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
        description: hash['description'],
        capabilities: hash['capabilities']
        )
    end

    private

    def search_with_status(q, status, conditions)
      search(q, conditions.merge(connection_status: status))
    end
  end
end
