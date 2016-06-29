require 'helper'

class PrinterTest < Minitest::Test
  def setup
    @client = new_client
  end

  should "initialize a printer" do
    printer = @client.printers.new(:id => 'printer_id', :status => 'online', :name => "My Printer")
    assert_equal 'printer_id', printer.id
    assert_equal 'online', printer.status
    assert_equal 'My Printer', printer.name
  end

  should "have tags" do
    printer = @client.printers.new(:id => 'printer_id', :status => 'online', :name => "My Printer")
    assert_equal printer.tags, {}

    printer = @client.printers.new(:id => 'printer_id', :status => 'online', :name => "My Printer", :tags => {"email" => 'a@b.com'})
    assert_equal printer.tags, {"email" => "a@b.com"}
  end

  should "get a connection when finding a printer by its id" do
    fake_connection.stubs(:get).returns(one_printer_hash)

    @client.expects(:connection).returns(fake_connection)
    @client.printers.find('printer')
  end

  should "call a remote request when finding a printer by its id" do
    fake_connection.expects(:get).returns(one_printer_hash)
    stub_connection
    @client.printers.find('printer')
  end

  should "call a remote request with the proper params when finding a printer" do
    fake_connection.expects(:get).with('/printer', :printerid => 'printer', :printer_connection_status => true).returns(one_printer_hash)
    stub_connection
    @client.printers.find('printer')
  end

  should "initialize a new object when finding a printer" do
    fake_connection.stubs(:get).returns(one_printer_hash)
    stub_connection
    printer = @client.printers.find('my_printer')
    assert_equal 'my_printer', printer.id
    assert_equal 'online', printer.status
    assert_equal 'My Printer', printer.name
    assert_equal printer.tags, {'email' => 'a@b.com' }
  end

  should "initialize an array of printers when finding all printers" do
    fake_connection.stubs(:get).returns(multiple_printer_hash)
    stub_connection
    printers = @client.printers.all
    first_printer = printers[0]
    second_printer  = printers[1]
    assert_equal 'first_printer', first_printer.id
    assert_equal 'second_printer', second_printer.id
    assert_equal 'First Printer', first_printer.name
    assert_equal 'Second Printer', second_printer.name
    assert_equal 'First Printer (display name)', first_printer.display_name
    assert_equal 'Second Printer (display name)', second_printer.display_name
    assert_equal 'First printer description', first_printer.description
    assert_equal 'Second printer description', second_printer.description
  end

  should "print stuff" do
    fake_connection.expects(:post).with('/submit', connection_print_params).returns(empty_job)
    stub_connection

    print_stuff
  end

  should "return an array of jobs" do
    stub_connection
    fake_connection.expects(:post).with('/jobs', {:printerid => "printer"}).returns(real_jobs_hash)

    print_job_array = get_all_jobs
    assert print_job_array.is_a?(Array)
    assert print_job_array.map(&:class).uniq.length.equal?(1)
    assert print_job_array.map(&:class).uniq.first.equal?(CloudPrint::PrintJob)
    assert print_job_array.length.equal?(3)
  end

  should "return a job" do
    stub_connection
    fake_connection.stubs(:post).with('/submit', connection_print_params).returns(empty_job)
    job = print_stuff
    assert job.is_a?(CloudPrint::PrintJob)
  end

  should "return nil when the response doesn't have job in it" do
    stub_connection
    fake_connection.stubs(:post).with('/submit', connection_print_params).returns({})
    job = print_stuff

    assert_nil job
  end

  should "print file" do
    fake_connection.expects(:multipart_post).with('/submit', connection_print_file_params).returns(empty_job)
    stub_connection

    print_file
  end

  should "print stringio" do
    stringio = StringIO.new(ruby_png_fixture.read)

    fake_connection.expects(:multipart_post).with('/submit', connection_print_file_params.merge(:content => stringio)).returns(empty_job)
    stub_connection

    printer = @client.printers.new(:id => 'printer')
    printer.print(print_file_params.merge(:content => stringio))
  end

  should "print tempfile" do
    Tempfile.open "cloundprint_test" do |tempfile|
      fake_connection.expects(:multipart_post).with('/submit', connection_print_file_params.merge(:content => tempfile)).returns(empty_job)
      stub_connection

      printer = @client.printers.new(:id => 'printer')
      printer.print(print_file_params.merge(:content => tempfile))
    end
  end

  should "print jobs returning an id and a status" do
    stub_connection
    fake_connection.expects(:post).with('/submit', connection_print_params).returns({"success" => true, "job" => {"id" => "job_id", "status" => 'status'}})
    job = print_stuff

    assert_equal 'job_id', job.id
    assert_equal 'status', job.status
  end

  %w{ONLINE UNKNOWN OFFLINE DORMANT}.each do |status|
    should "recognize a printer as #{status.downcase}" do
      printer = @client.printers.new(:connection_status => status)

      assert printer.send(status.downcase + '?')

      %w{ONLINE UNKNOWN OFFLINE DORMANT}.reject{ |s| s == status}.each do |other_statuses|
        assert !printer.send(other_statuses.downcase + '?')
      end
    end

    context ".search_#{status.downcase}" do
      should "scope search by connection status '#{status}'" do
        stub_connection
        fake_connection.expects(:get).with('/search', { :q => 'query', :connection_status => status.upcase }).returns(one_printer_hash)
        @client.printers.send("search_#{status.downcase}", 'query')
      end

      should "return array of Printers" do
        stub_connection
        fake_connection.stubs(:get).with('/search', { :connection_status => status }).returns(one_printer_hash)
        printers = @client.printers.send("search_#{status.downcase}")
        assert_equal 'my_printer', printers[0].id
      end
    end
  end

  context '.search_all' do
    setup { stub_connection }

    should "search printers regardless of connection status" do
      fake_connection.expects(:get).with('/search', { :q => 'query' }).returns(one_printer_hash)
      @client.printers.search_all 'query'
    end

    should "return array of Printers" do
      fake_connection.stubs(:get).with('/search', {}).returns(one_printer_hash)
      printers = @client.printers.search_all
      assert_equal 'my_printer', printers[0].id
    end
  end

  context '.all' do
    should 'call .search with no query' do
      @client.printers.expects(:search)
      @client.printers.all
    end
  end

  context '.search' do
    setup do
      stub_connection
      fake_connection.expects(:get).with('/search', { :q => 'query' }).returns(one_printer_hash)
    end

    should "not scope printer search by connection status" do
      @client.printers.search 'query'
    end

    should "return array of Printers" do
      printers = @client.printers.search 'query'
      assert_equal 'my_printer', printers[0].id
    end
  end

  private

  def empty_job
    {"job" => {}}
  end

  def print_stuff
    printer = @client.printers.new(:id => 'printer')
    printer.print(print_params)
  end

  def get_all_jobs
    printer = @client.printers.new(:id => 'printer')
    printer.all_jobs
  end

  def print_params
     { :title => "Hello World", :content => "<h1>ohai!</h1>", :content_type => "text/html", :ticket => ticket_hash }
  end

  def connection_print_params
    { :printerid => 'printer', :title => "Hello World", :content => "<h1>ohai!</h1>", :contentType => "text/html", :ticket => ticket_hash.to_json }
  end

  def print_file
    printer = @client.printers.new(:id => 'printer')
    printer.print(print_file_params)
  end

  def print_file_params
    { :title => "Ruby!", :content => ruby_png_fixture, :content_type => "image/png", :ticket => ticket_hash }
  end

  def connection_print_file_params
    { :printerid => 'printer', :title => "Ruby!", :content => ruby_png_fixture, :contentType => "image/png", :ticket => ticket_hash.to_json }
  end

  def one_printer_hash
    {'printers' =>[{'id' => 'my_printer', 'status' => 'online', 'name' => "My Printer", 'displayName' => 'My Printer (display name)', 'tags' => { 'email' => 'a@b.com'}}]}
  end

  def multiple_printer_hash
    {'printers' =>[
        {'id' => 'first_printer',  'status' => 'online', 'name' => "First Printer", 'displayName' => 'First Printer (display name)', 'description' => 'First printer description'},
        {'id' => 'second_printer', 'status' => 'online', 'name' => "Second Printer", 'displayName' => 'Second Printer (display name)', 'description' => 'Second printer description'}
    ]}
  end

  def ticket_hash
    { 'version' => '1.0',
      'print' => {
        'vendor_ticket_item' => [
          {'id' => 'PageRegion', 'value' => "Letter"},
          {'id' => 'BRMediaType', 'value' => 'Plain'},
          {'id' => 'InputSlot', 'value' => 'Tray1'}
        ],
        'page_orientation' => {'type' => 2},
        'fit_to_page' => {'type' => 3}
      }
    }
  end

  def ruby_png_fixture
    @ruby_png_fixture ||= File.open(fixture_file('ruby.png'))
  end

  def real_jobs_hash
    {
      "success" => true,
      "request" => {
        "time" => "0",
        "params" => {
          "owner" => [
            ""
          ],
          "q" => [
            ""
          ],
          "offset" => [
            ""
          ],
          "limit" => [
            ""
          ],
          "printerid" => [
            "c3066017-5787-d8ac-1611-cc7a3e05cff1"
          ],
          "sortorder" => [
            ""
          ],
          "status" => [
            ""
          ]
        },
        "user" => "santa@claus.com",
        "users" => [
          "santa@claus.com"
        ]
      },
      "xsrf_token" => "AIp06DgE7d7xYChj2WA-qZtkVVEorov9fA:1465416906512",
      "jobs" => [
        {
          "ticketUrl" => "https://www.google.com/cloudprint/ticket?format\u003dxps\u0026output\u003dxml\u0026jobid\u003d3f87deef-6d0f-85a0-5c31-268b001fc592",
          "printerType" => "GOOGLE",
          "printerName" => "Brother HL-L2360D series - #1",
          "errorCode" => "",
          "updateTime" => "1465416896913",
          "title" => "792204",
          "message" => "",
          "ownerId" => "santa@claus.com",
          "tags" => [
            "^own"
          ],
          "uiState" => {
            "summary" => "IN_PROGRESS"
          },
          "numberOfPages" => 1,
          "createTime" => "1465416894322",
          "semanticState" => {
            "delivery_attempts" => 1,
            "state" => {
              "type" => "IN_PROGRESS"
            },
            "version" => "1.0"
          },
          "printerid" => "c3066017-5787-d8ac-1611-cc7a3e05cff0",
          "fileUrl" => "https://www.google.com/cloudprint/download?id\u003d3f87deef-6d0f-85a0-5c31-268b001fc592",
          "id" => "3f87deef-6d0f-85a0-5c31-268b001fc592",
          "rasterUrl" => "https://www.google.com/cloudprint/download?id\u003d3f87deef-6d0f-85a0-5c31-268b001fc592\u0026forcepwg\u003d1",
          "contentType" => "text/html",
          "status" => "IN_PROGRESS"
        },
        {
          "ticketUrl" => "https://www.google.com/cloudprint/ticket?format\u003dxps\u0026output\u003dxml\u0026jobid\u003dba4b9c8e-818a-a514-8c06-9d353e5da16c",
          "printerType" => "GOOGLE",
          "printerName" => "Brother HL-L2360D series - #1",
          "errorCode" => "",
          "updateTime" => "1465416776902",
          "title" => "791881",
          "message" => "",
          "ownerId" => "santa@claus.com",
          "tags" => [
            "^own"
          ],
          "uiState" => {
            "summary" => "DONE"
          },
          "numberOfPages" => 1,
          "createTime" => "1465416745338",
          "semanticState" => {
            "delivery_attempts" => 1,
            "state" => {
              "type" => "DONE"
            },
            "version" => "1.0"
          },
          "printerid" => "c3066017-5787-d8ac-1611-cc7a3e05cff0",
          "fileUrl" => "https://www.google.com/cloudprint/download?id\u003dba4b9c8e-818a-a514-8c06-9d353e5da16c",
          "id" => "ba4b9c8e-818a-a514-8c06-9d353e5da16c",
          "rasterUrl" => "https://www.google.com/cloudprint/download?id\u003dba4b9c8e-818a-a514-8c06-9d353e5da16c\u0026forcepwg\u003d1",
          "contentType" => "text/html",
          "status" => "DONE"
        },
        {
          "ticketUrl" => "https://www.google.com/cloudprint/ticket?format\u003dxps\u0026output\u003dxml\u0026jobid\u003d00c7b2d7-97ca-7de1-5f82-11c252fbce90",
          "printerType" => "GOOGLE",
          "printerName" => "XEROX PRINTER",
          "errorCode" => "",
          "updateTime" => "1465416662337",
          "title" => "790452",
          "message" => "",
          "ownerId" => "santa@claus.com",
          "tags" => [
            "^own"
          ],
          "uiState" => {
            "summary" => "DONE"
          },
          "numberOfPages" => 1,
          "createTime" => "1465416628670",
          "semanticState" => {
            "delivery_attempts" => 1,
            "state" => {
              "type" => "DONE"
            },
            "version" => "1.0"
          },
          "printerid" => "c3066017-5787-d8ac-1611-cc7a3e05cff0",
          "fileUrl" => "https://www.google.com/cloudprint/download?id\u003d00c7b2d7-97ca-7de1-5f82-11c252fbce90",
          "id" => "00c7b2d7-97ca-7de1-5f82-11c252fbce90",
          "rasterUrl" => "https://www.google.com/cloudprint/download?id\u003d00c7b2d7-97ca-7de1-5f82-11c252fbce90\u0026forcepwg\u003d1",
          "contentType" => "text/html",
          "status" => "DONE"
        }
      ],
      "range" => {
        "jobsTotal" => "101",
        "jobsCount" => 2
      }
    }
  end
end
