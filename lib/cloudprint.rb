require "rubygems"
require "bundler/setup"
require "oauth2"
require "json"
require "active_support/core_ext/object"
require "active_support/core_ext/module"
require "active_support/core_ext/hash/keys"

require "cloudprint/base"
require "cloudprint/version"
require "cloudprint/printer_collection"
require "cloudprint/printer"
require "cloudprint/connection"
require "cloudprint/print_job_collection"
require "cloudprint/print_job"
require "cloudprint/exceptions"

module CloudPrint
  class << self
    def setup *args
      CloudPrint::Base.new(*args)
    end
  end
end
