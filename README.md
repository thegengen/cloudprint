# Cloudprint [![Build Status](https://travis-ci.org/thegengen/cloudprint.svg?branch=master)](https://travis-ci.org/thegengen/cloudprint)

Cloudprint is a Ruby library for interacting with Google's Cloud Print service, a technology that allows you to print over the web from anywhere to any printer.

## Setting things up.
To start using cloudprint, you first need to add it to your Gemfile, with an entry such as this:

```ruby
gem 'cloudprint'
```

Afterwards, run `bundle install` 

Next, you'll need to authenticate your users with Google Cloud Print. Cloud Print uses OAuth2 as an authentication mechanism.

First, you need to register your application within the Google Console. To do that, go to [https://cloud.google.com/console](https://cloud.google.com/console). Doing this will provide you with two things that will be needed to manage your users' printers: a client ID and a client secret.

## Authenticating your users.
Once you've registered your application, you will need to send your users to a URL where they can allow your application to manage their printer. You will also need to specify a URL *of yours* where they will be sent back after giving you access.

```ruby
client = CloudPrint::Client.new(client_id: 'your_app_id', client_secret: 'your_app_secret')
redirect_url = 'http://your.app/redirect_uri'
client.auth.generate_url(redirect_url)
```

When they come, their request to your URL will have an extra parameter named 'code' attached to it. You then exchange this code for a refresh token. Note that you also have to include the redirect URL which you specified above.

```ruby
code = params[:code]
token = client.auth.generate_token(code, redirect_url)
```

The client is all set to start using the URI, but you will want to store this refresh token so you can get access again at a later time. Subsequently, you can set the refresh token on `Cloudprint::Client` instances yourself.

```ruby
client = CloudPrint::Client.new(
  refresh_token: 'refresh_token',
  client_id: 'your_app_id',
  client_secret: 'your_app_secret',
)
```

With this in place — and with the user's printer set up from the CloudPrint UI — you now have everything you need to start using their printer.

## Printing
Printing with the cloudprint gem is done with two kinds of objects. `CloudPrint::Printer` objects represent printers your users have set up in their CloudPrint accounts. You then ask these objects to print things like this:

```ruby
# Get a list of all the printers this client can talk to.
printers = client.printers.all                      

# Get a printer with a specific id
my_printer = client.printers.find('printer_id')

# Print using this printer.
# The :content option can also take a File object as a parameter. 
# CloudPrint accepts HTML and PDF files.
my_printer.print(content: "<h1>Hello World</h1>", content_type: "text/html")
```

Here's where the second kind of object comes in. If your content has been succesfully sent to the printer, the cloudprint gem will return a `CloudPrint::PrintJob` object. Among other things, this object will provide you with an ID for the print job and, a status code, and an error code if anything happened that prevented your document from getting printed.

Most of the time, the PrintJob object that your print() call will return has a status of `IN_PROGRESS` or `QUEUED`.

If your application can simply wait for the job, you can call refresh! on your print job until its status changes. If not, you can store the ID and fetch the print job at a later time to verify its status.

```ruby
my_job = client.print_jobs.find('job_id')

# Returns the status, one of QUEUED, IN_PROGRESS, DONE, ERROR, SUBMITTED
my_job.status 
```

You can also delete a job, after it has finished.

```ruby
my_job.delete!
```

## Example Print Parameters
While sending the print option to google coudprint we need to set some custom parameters an exmaple of all the parameters below:

```ruby
my_printer.print(
  content: "<h1>Hello World</h1>", 
  content_type: "text/html", 
  title: 'Example Title', 
  ticket: {
    version: "1.0",
    print: {
      vendor_ticket_item:
        [
          { id: "psk:PageMediaType", value: "psk:Plain" },
          { id: "force-pwg-raster", value: "false" }
        ],
      color:{ vendor_id: "", type: 1 },
      duplex:{ type: 0 },
      page_orientation: { type: 2 },
      copies: { copies: 1 },
      dpi: { horizontal_dpi: 300,vertical_dpi: 300, vendor_id: "" },
      fit_to_page: { type: 3 },
      media_size: { width_microns: 210000, height_microns: 297000, is_continuous_feed: false, vendor_id: "2" },
      collate: { collate: false },
      reverse_order: { reverse_order: false }
    }
  }
)
```
Note that for using pdf your need to set 

```ruby
  content: open(file_path, r),
  content_type: 'application/pdf'
```

## Testing
For your testing needs, cloudprint objects can be stubbed at will and initializing them does not require a connection. For example, to stub a print() call with the shoulda library, one would do this:

```ruby
my_printer = CloudPrint::Printer.new(id: 'id', status: 'OK', name: 'test_printer', display_name: 'Test Printer'
my_job = CloudPrint::PrintJob.new({}) # see the PrintJob class for what this hash can hold
my_printer.stubs(:print).returns(my_job)
```

## More help
Please submit an issue via GitHub if you need more help with the cloudprint gem.
