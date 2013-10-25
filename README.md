## Cloudprint
Cloudprint is a Ruby library for interacting with Google's Cloud Print service,
a technology that allows you to print over the web from anywhere to any
printer.

### Setting things up.
To start using cloudprint, you first need to add it to your Gemfile, with an
entry such as this.

```ruby
gem 'cloudprint'
```

Afterwards, run 
```
bundle
```

Next, you'll need to authenticate your users with Google Cloud Print. Cloud
Print uses OAuth2 as an authentication mechanism.

First, you need to register your application within the Google Console. To do
that, go to [https://cloud.google.com/console](https://cloud.google.com/console) 
. Doing this will provide you with two things that will be needed to manage
your users' printers: a client ID and a client secret.  

### Authenticating your users.
Once you've registered your application, you will need to send your users to a
URL where they can allow your application to manage their printer.

Details on how such a URL can be built can be found here:
[https://developers.google.com/accounts/docs/OAuth2WebServer#formingtheurl](https://developers.google.com/accounts/docs/OAuth2WebServer#formingtheurl)

Eventually, the cloudprint gem will generate these URLs for you, but for now
you're on your own. Sorry about that.

Your users will be asked to sign into their Google Account and to enable your
app to manage their printer. Later on, they can then set up their printer from
the Google Cloud Print interface.

Once users authorize your application, they will be sent back to a URL you
specify which will have an extra parameter named 'code' attached to it.
You then exchange this code for a refresh token.
Instructions on how to get a refresh token can be found here:
[https://developers.google.com/accounts/docs/OAuth2WebServer#handlingtheresponse](https://developers.google.com/accounts/docs/OAuth2WebServer#handlingtheresponse)

With this in place (and with the user's printer set up from the CloudPrint UI)
you now have everything you need to send print jobs to this printer.

### Printing
First, you need to set up your connection with the data you just got from the user.

```ruby
CloudPrint.setup(
  refresh_token: 'refresh_token',
  client_id: 'client_id',
  client_secret: 'client_secret',
  callback_url: 'callback_url'
)
```
We realize that having a global object for this is less than ideal. If you need to have
multiple connections, you have a good chance to get some open source work under
your belt. ;)

Printing with the cloudprint gem is done with two kinds of objects. 
`CloudPrint::Printer` 
objects represent printers your users have set up in their CloudPrint accounts.
You then ask these objects to print things like this:

```ruby
printers = CloudPrint::Printer.all                  # this will return a list of printers.
my_printer = CloudPrint::Printer.find('printer_id') # this will get a printer with a specific id.

my_printer.print(content: "<h1>Hello World</h1>") # the :content option can also take a File object as a parameter, CloudPrint accepts HTML and PDF files.
```

Here's where the second kind of object comes in. If your content has been
succesfully sent to the printer, the cloudprint gem will return a `CloudPrint::PrintJob` 
object. Among other things, this object will provide you with an ID for the print job
and, a status code, and an error code if anything happened that prevented your document from
getting printed.

Most of the time, the PrintJob object that your print() call will return will
have a status of `IN_PROGRESS` or `QUEUED`.

If your application can simply wait for the job, you can call refresh! on your
print job until its status changes. If not, you can store the ID and fetch the print job
at a later time to verify its status.

```ruby
my_job = CloudPrint::PrintJob.find('job_id')
my_job.status # returns the status, one of QUEUED, IN_PROGRESS, DONE, ERROR, SUBMITTED
```

You can also delete a job, after it has finished.

```ruby
my_job.delete!
```

=== Testing
For your testing needs, cloudprint objects can be stubbed at will and initializing them does not require a connection. For example,
to stub a print() call with the shoulda library, one would do this:

```ruby
my_printer = CloudPrint::Printer.new(id: 'id', status: 'OK', name: 'test_printer', display_name: 'Test Printer'
my_job = CloudPrint::PrintJob.new({}) # see the PrintJob class for what this hash can hold
my_printer.stubs(:print).returns(my_job)
```

### More help
Please submit an issue via GitHub if you need more help with the cloudprint gem.
