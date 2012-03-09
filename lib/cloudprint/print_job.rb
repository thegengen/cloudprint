module CloudPrint
  class PrintJob
    attr_reader :id, :status, :error_code
    def initialize(options = {})
      @id = options[:id]
      @status = options[:status]
      @error_code = options[:error_code]
    end

    def self.find(jobid)
      response = CloudPrint.connection.get('/jobs') || {}
      return nil unless response['jobs'].is_a?(Array)
      job = response['jobs'].select{ |job| job['id'] == jobid }.first
      return nil if job.nil?
      self.new(:id => job['id'], :status => job['status'], :error_code => job['errorCode'])
    end

    def queued?
      status == "QUEUED"
    end

    def in_progress?
      status == "IN_PROGRESS"
    end

    def done?
      status == "DONE"
    end

    def error?
      status == "ERROR"
    end
  end
end