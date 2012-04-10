require 'helper'

class PrintJobTest < Test::Unit::TestCase
  def setup
    # TODO: Is it necessary to pass a fake token to #setup?
    CloudPrint.setup(:refresh_token => 'refresh_token')
    stub_connection
  end

  should "find a job" do
    fake_connection.stubs(:get).with('/jobs').returns(jobs_response)
    assert CloudPrint::PrintJob.find('job_id').is_a?(CloudPrint::PrintJob)
  end

  should 'perform a remote request when finding a job' do
    fake_connection.expects(:get).with('/jobs').returns({})

    CloudPrint::PrintJob.find('job_id')
  end

  should 'gets the job details' do
    fake_connection.stubs(:get).with('/jobs').returns(jobs_response)
    job = CloudPrint::PrintJob.find('job_id')

    assert_equal 'job_id', job.id
    assert_equal 'status', job.status
    assert_equal 'Error', job.error_code
  end

  should 'recognize a job as queued' do
    job = CloudPrint::PrintJob.new(:status => "QUEUED")

    assert !job.done?
    assert !job.in_progress?
    assert !job.error?

    assert job.queued?
  end

  should 'recognize a job as in progress' do
    job = CloudPrint::PrintJob.new(:status => "IN_PROGRESS")

    assert !job.done?
    assert !job.queued?
    assert !job.error?

    assert job.in_progress?
  end

  should 'recognize a job as done' do
    job = CloudPrint::PrintJob.new(:status => "DONE")

    assert !job.in_progress?
    assert !job.queued?
    assert !job.error?

    assert job.done?
  end

  should "recognize a job has an error" do
    job = CloudPrint::PrintJob.new(:status => "ERROR")

    assert !job.done?
    assert !job.in_progress?
    assert !job.queued?

    assert job.error?
  end

  should "refresh a job" do
    job = CloudPrint::PrintJob.new(:status => "IN_PROGRESS")
    CloudPrint::PrintJob.stubs(:find_by_id).returns({"id" => "job_id", "status" => "DONE", "errorCode" => "42"})

    assert_equal job, job.refresh!

    assert job.done?
    assert_equal "42", job.error_code
  end

  private

  def jobs_response
    {
      "jobs" => [
        {"id" => "other_job", "status" => "status", "errorCode" => "Error"},
        {"id" => "job_id", "status" => "status", "errorCode" => "Error"}
      ]
    }
  end
end
