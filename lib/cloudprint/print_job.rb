module CloudPrint
  class PrintJob
    STATUSES = %w{QUEUED IN_PROGRESS DONE ERROR SUBMITTED}

    def initialize(data)
      @data = data
    end

    def self.find(jobid)
      job = find_by_id(jobid)
      return nil if job.nil?
      new_from_response job
    end

    def self.all
      fetch_jobs.map { |j| new_from_response j }
    end

    def refresh!
      @data = self.class._normalize_response_data(self.class.find_by_id(id))
      self
    end

    def delete!
      response = CloudPrint.connection.get('/deletejob', { :jobid => id })
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

  private

    def self.find_by_id(id)
      fetch_jobs.select{ |job| job['id'] == id }.first
    end

    def self.fetch_jobs
      response = CloudPrint.connection.get('/jobs') || {}
      response['jobs'] || []
    end

    def self.new_from_response(response_hash)
      new _normalize_response_data(response_hash)
    end

    def self._normalize_response_data(response_hash)
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
