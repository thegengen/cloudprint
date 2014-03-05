module CloudPrint
  class PrintJobCollection

    attr_accessor :base
    delegate :connection, to: :base
    
    def initialize base
      @base = base
    end
    
    def find(jobid)
      job = find_by_id(jobid)
      return nil if job.nil?
      new_from_response job
    end

    def all
      fetch_jobs.map { |j| new_from_response j }
    end

    def new data
      PrintJob.new base, data
    end

    def new_from_response response
      PrintJob.new_from_response base, response
    end

    private

    def find_by_id(id)
      fetch_jobs.select{ |job| job['id'] == id }.first
    end

    def fetch_jobs
      response = connection.get('/jobs') || {}
      response['jobs'] || []
    end
  end
end
