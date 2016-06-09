require 'helper'

class PrintJobTest < Minitest::Test
  def setup
    # TODO: Is it necessary to pass a fake token to #setup?
    @client = new_client
    stub_connection
  end

  should "find a job" do
    fake_connection.stubs(:get).with('/jobs').returns(jobs_response)
    assert @client.print_jobs.find('job_id').is_a?(CloudPrint::PrintJob)
  end

  should "find a job" do
    fake_connection.expects(:post).with('/job', {:jobid => "aaaa"}).returns(real_job_hash)
    assert CloudPrint::PrintJob.find_job(@client, 'aaaa').is_a?(CloudPrint::PrintJob)
  end

  should 'perform a remote request when finding a job' do
    fake_connection.expects(:get).with('/jobs').returns({})

    @client.print_jobs.find('job_id')
  end

  should 'gets the job details' do
    fake_connection.stubs(:get).with('/jobs').returns(jobs_response)
    job = @client.print_jobs.find('job_id')

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
    job = @client.print_jobs.new(:status => "QUEUED")

    assert !job.done?
    assert !job.in_progress?
    assert !job.error?
    assert !job.submitted?

    assert job.queued?
  end

  should 'recognize a job as in progress' do
    job = @client.print_jobs.new(:status => "IN_PROGRESS")

    assert !job.done?
    assert !job.queued?
    assert !job.error?
    assert !job.submitted?

    assert job.in_progress?
  end

  should 'recognize a job as done' do
    job = @client.print_jobs.new(:status => "DONE")

    assert !job.in_progress?
    assert !job.queued?
    assert !job.error?
    assert !job.submitted?

    assert job.done?
  end

  should "recognize a job has an error" do
    job = @client.print_jobs.new(:status => "ERROR")

    assert !job.done?
    assert !job.in_progress?
    assert !job.queued?
    assert !job.submitted?

    assert job.error?
  end

  should "recognize a job as submitted" do
    job = @client.print_jobs.new(:status => "SUBMITTED")

    assert !job.done?
    assert !job.in_progress?
    assert !job.queued?
    assert !job.error?

    assert job.submitted?
  end

  should "refresh a job" do
    job = @client.print_jobs.new(:id => "job_id", :status => "IN_PROGRESS")
    @client.print_jobs.stubs(:find_by_id).returns({"id" => "job_id", "status" => "DONE", "errorCode" => "42"})

    assert_equal job, job.refresh!

    assert job.done?
    assert_equal "42", job.error_code
  end

  should "return all jobs" do
    fake_connection.stubs(:get).with('/jobs').returns(jobs_response)
    jobs = @client.print_jobs.all

    assert jobs[0].id == 'other_job'
    assert jobs[1].id == 'job_id'
  end

  context '#delete!' do
    should "return true on success" do
      fake_connection.stubs(:get).with('/deletejob', { :jobid => 'job_id' }).returns({ 'success' => true })

      assert @client.print_jobs.new(:id => 'job_id').delete!
    end

    should "perform a remote request" do
      fake_connection.expects(:get).with('/deletejob', { :jobid => 'job_id' }).returns({ 'success' => true })

      @client.print_jobs.new(:id => 'job_id').delete!
    end

    should "raise a RequestError on failure" do
      fake_connection.stubs(:get).with('/deletejob', { :jobid => 'job_id' }).returns({ 'success' => false, 'message' => 'This is an error', 'errorCode' => '123' })

      assert_raises(CloudPrint::RequestError, 'This is an error') do
        @client.print_jobs.new(:id => 'job_id').delete!
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

  def real_job_hash
    {
      "success" => true,
      "request" => {
        "time" => "0",
        "params" => {
          "jobid" => [
            "aaaa"
          ]
        },
        "user" => "donald@trump.com",
        "users" => [
          "donald@trump.com"
        ]
      },
      "xsrf_token" => "AIp06DiNzjnfseYdqxujmG5P5oDpPh3N_A:1465433435813",
      "job" => {
        "ticketUrl" => "https://www.google.com/cloudprint/ticket?format\u003dxps\u0026output\u003dxml\u0026jobid\u003db8fa1266-625b-070c-5968-5039d2fdb982",
        "printerType" => "GOOGLE",
        "printerName" => "Brother HL-L2380DW series",
        "errorCode" => "",
        "updateTime" => "1465414297946",
        "title" => "791947",
        "message" => "",
        "ownerId" => "donald@trump.com",
        "tags" => [
          "^own"
        ],
        "uiState" => {
          "summary" => "DONE"
        },
        "numberOfPages" => 1,
        "createTime" => "1465414267720",
        "semanticState" => {
          "delivery_attempts" => 1,
          "state" => {
            "type" => "DONE"
          },
          "version" => "1.0"
        },
        "printerid" => "cef403bb-d914-1a7d-f0a3-8190e1ff173a",
        "fileUrl" => "https://www.google.com/cloudprint/download?id\u003db8fa1266-625b-070c-5968-5039d2fdb982",
        "id" => "aaaa",
        "rasterUrl" => "https://www.google.com/cloudprint/download?id\u003db8fa1266-625b-070c-5968-5039d2fdb982\u0026forcepwg\u003d1",
        "contentType" => "application/pdf",
        "status" => "DONE"
      }
    }
  end
end
