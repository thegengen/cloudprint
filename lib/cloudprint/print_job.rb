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

    def method_missing(meth, *args, &block)
      if [:id, :status, :error_code].include?(meth)
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
        :error_code => response_hash['errorCode']
      }
    end
  end
end
