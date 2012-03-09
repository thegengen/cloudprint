require 'helper'

class PrintJobTest < Test::Unit::TestCase
  def setup
    # TODO: Is it necessary to pass a fake token to #setup?
    CloudPrint.setup(:refresh_token => 'refresh_token')
    stub_connection
  end

  test "find a job" do
    fake_connection.stubs(:get).with('/jobs').returns(job_response)
    assert CloudPrint::PrintJob.find('job_id').is_a?(CloudPrint::PrintJob)
  end

  test 'find a job performs a remote request' do
    fake_connection.expects(:get).with('/jobs').returns({})

    CloudPrint::PrintJob.find('job_id')
  end

  test 'find a job gets the job details' do
    fake_connection.stubs(:get).with('/jobs').returns(job_response)
    job = CloudPrint::PrintJob.find('job_id')

    assert_equal 'job_id', job.id
    assert_equal 'status', job.status
    assert_equal 'Error', job.error_code
  end

  test 'a job is queued' do
    job = CloudPrint::PrintJob.new(:status => "QUEUED")

    assert !job.done?
    assert !job.in_progress?
    assert !job.error?

    assert job.queued?
  end

  test 'a job is in progress' do
    job = CloudPrint::PrintJob.new(:status => "IN_PROGRESS")

    assert !job.done?
    assert !job.queued?
    assert !job.error?

    assert job.in_progress?
  end

  test 'a job is done' do
    job = CloudPrint::PrintJob.new(:status => "DONE")

    assert !job.in_progress?
    assert !job.queued?
    assert !job.error?

    assert job.done?
  end

  test "a job has an error" do
    job = CloudPrint::PrintJob.new(:status => "ERROR")

    assert !job.done?
    assert !job.in_progress?
    assert !job.queued?

    assert job.error?
  end

  test "refreshing a job" do
    job = CloudPrint::PrintJob.new(:status => "IN_PROGRESS")
    CloudPrint::PrintJob.stubs(:find_by_id).returns({"id" => "job_id", "status" => "DONE", "errorCode" => "42"})

    assert_equal job, job.refresh!

    assert job.done?
    assert_equal "42", job.error_code
  end

  private

  def job_response
    {
      "jobs" => [
        {"id" => "other_job", "status" => "status", "errorCode" => "Error"},
        {"id" => "job_id", "status" => "status", "errorCode" => "Error"}
      ]
    }
  end
end