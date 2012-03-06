require 'helper'

class PrintJobTest < Test::Unit::TestCase
  def setup
    # TODO: Is it necessary to pass a fake token to #setup?
    CloudPrint.setup(:refresh_token => 'refresh_token')
    stub_connection
  end

  test "find a job" do
    fake_connection.stubs(:post).with('/jobs', :jobid => 'job_id').returns(job_response)
    assert CloudPrint::PrintJob.find('job_id').is_a?(CloudPrint::PrintJob)
  end

  # Google doesn't list jobid as a possible value in its public docs, but it seems to work just fine
  test 'find a job performs a remote request' do
    fake_connection.expects(:post).with('/jobs', :jobid => 'job_id').returns({})

    CloudPrint::PrintJob.find('job_id')
  end

  test 'find a job gets the job details' do
    fake_connection.stubs(:post).with('/jobs', :jobid => 'job_id').returns(job_response)
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
  private

  def job_response
    {"jobs" => [{"id" => "job_id", "status" => "status", "errorCode" => "Error"}]}
  end
end