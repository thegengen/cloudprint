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

    def find_by_id(id)
      response = client.connection.post('/job', :jobid => id) || {}
      return nil if response.nil? || response["job"].nil?
      response["job"]
    end

    private

    def fetch_jobs
      response = client.connection.get('/jobs') || {}
      response['jobs'] || []
    end
  end
end
