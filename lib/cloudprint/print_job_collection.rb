module CloudPrint
  class PrintJobCollection

    attr_accessor :client
    
    def initialize client
      @client = client
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
      PrintJob.new client, data
    end

    def new_from_response response
      PrintJob.new_from_response client, response
    end

    private

    def find_by_id(id)
      fetch_jobs.select{ |job| job['id'] == id }.first
    end

    def fetch_jobs
      response = client.connection.get('/jobs') || {}
      response['jobs'] || []
    end
  end
end
