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
    assert_equal 'printer_id', job.printer_id
    assert_equal 'Job Title', job.title
    assert_equal 'image/jpeg', job.content_type
    assert_equal 'https://www.google.com/cloudprint/download?id=job_id', job.file_url
    assert_equal 'https://www.google.com/cloudprint/ticket?jobid=job_id', job.ticket_url
    assert_equal Time.at(1349722237.676), job.create_time
    assert_equal Time.at(1349722237.676), job.update_time
    assert_equal 'A message.', job.message
    assert_equal ["^own"], job.tags
  end

  should 'recognize a job as queued' do
    job = CloudPrint::PrintJob.new(:status => "QUEUED")

    assert !job.done?
    assert !job.in_progress?
    assert !job.error?
    assert !job.submitted?

    assert job.queued?
  end

  should 'recognize a job as in progress' do
    job = CloudPrint::PrintJob.new(:status => "IN_PROGRESS")

    assert !job.done?
    assert !job.queued?
    assert !job.error?
    assert !job.submitted?

    assert job.in_progress?
  end

  should 'recognize a job as done' do
    job = CloudPrint::PrintJob.new(:status => "DONE")

    assert !job.in_progress?
    assert !job.queued?
    assert !job.error?
    assert !job.submitted?

    assert job.done?
  end

  should "recognize a job has an error" do
    job = CloudPrint::PrintJob.new(:status => "ERROR")

    assert !job.done?
    assert !job.in_progress?
    assert !job.queued?
    assert !job.submitted?

    assert job.error?
  end

  should "recognize a job as submitted" do
    job = CloudPrint::PrintJob.new(:status => "SUBMITTED")

    assert !job.done?
    assert !job.in_progress?
    assert !job.queued?
    assert !job.error?

    assert job.submitted?
  end

  should "refresh a job" do
    job = CloudPrint::PrintJob.new(:id => "job_id", :status => "IN_PROGRESS")
    CloudPrint::PrintJob.stubs(:find_by_id).returns({"id" => "job_id", "status" => "DONE", "errorCode" => "42"})

    assert_equal job, job.refresh!

    assert job.done?
    assert_equal "42", job.error_code
  end

  should "return all jobs" do
    fake_connection.stubs(:get).with('/jobs').returns(jobs_response)
    jobs = CloudPrint::PrintJob.all

    assert jobs[0].id == 'other_job'
    assert jobs[1].id == 'job_id'
  end

  context '#delete!' do
    should "return true on success" do
      fake_connection.stubs(:get).with('/deletejob', { :jobid => 'job_id' }).returns({ 'success' => true })

      assert CloudPrint::PrintJob.new(:id => 'job_id').delete!
    end

    should "perform a remote request" do
      fake_connection.expects(:get).with('/deletejob', { :jobid => 'job_id' }).returns({ 'success' => true })

      CloudPrint::PrintJob.new(:id => 'job_id').delete!
    end

    should "raise a RequestError on failure" do
      fake_connection.stubs(:get).with('/deletejob', { :jobid => 'job_id' }).returns({ 'success' => false, 'message' => 'This is an error', 'errorCode' => '123' })

      assert_raise(CloudPrint::RequestError, 'This is an error') do
        CloudPrint::PrintJob.new(:id => 'job_id').delete!
      end
    end
  end

  private

  def jobs_response
    {
      "jobs" => [
        { "id" => "other_job", "status" => "status", "errorCode" => "Error" },
        {
          "id" => "job_id",
          "status" => "status",
          "errorCode" => "Error",
          "printerid" => "printer_id",
          "title" => "Job Title",
          "contentType" => "image/jpeg",
          "fileUrl" => "https://www.google.com/cloudprint/download?id=job_id",
          "ticketUrl" => "https://www.google.com/cloudprint/ticket?jobid=job_id",
          "createTime" => "1349722237676",
          "updateTime" => "1349722237676",
          "message" => "A message.",
          "tags" => ["^own"]
        }
      ]
    }
  end
end
