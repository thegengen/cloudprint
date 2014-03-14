module CloudPrint
  class PrintJob
    STATUSES = %w{QUEUED IN_PROGRESS DONE ERROR SUBMITTED}

    attr_reader :client

    class << self
      def new_from_response client, response_hash
        new client, Util.normalize_response_data(response_hash)
      end
    end

    def initialize(client, data)
      @client = client
      @data = data
    end

    def refresh!
      @data = Util.normalize_response_data(client.print_jobs.find_by_id(id))
      self
    end

    def delete!
      response = client.connection.get('/deletejob', { :jobid => id })
      response['success'] || raise(RequestError, response['message'])
    end

    def method_missing(meth, *args, &block)
      if @data.has_key?(meth)
        @data[meth]
      elsif STATUSES.map{ |s| s.downcase + '?' }.include?(meth.to_s)
        @data[:status].downcase == meth.to_s.chop
      else
        super
      end
    end

    module Util
      def self.normalize_response_data(response_hash)
        {
          :id => response_hash['id'],
          :status => response_hash['status'],
          :error_code => response_hash['errorCode'],
          :printer_id => response_hash['printerid'],
          :title => response_hash['title'],
          :content_type => response_hash['contentType'],
          :file_url => response_hash['fileUrl'],
          :ticket_url => response_hash['ticketUrl'],
          :create_time => Time.at(response_hash['createTime'].to_f / 1000),
          :update_time => Time.at(response_hash['updateTime'].to_f / 1000),
          :message => response_hash['message'],
          :tags => response_hash['tags']
        }
      end
    end
  end
end
