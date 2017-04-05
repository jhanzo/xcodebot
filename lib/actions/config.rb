require 'yaml'
require 'uri'
require 'net/http'
require 'openssl'
require 'helpers/url.rb'

module Xcodebot
    class Config

        def self.hostname
            return ENV['XCODEBOT_SERVER']
        end

        def self.run
            #if arguments provided
            if ARGV.size > 0
                if (["--list","-l"] & ARGV).size > 0
		    abort "Please fill env var XCODEBOT_SERVER".red if !ENV['XCODEBOT_SERVER']
                    Xcodebot::Url.display_url(Xcodebot::Url.check_url(ENV['XCODEBOT_SERVER']))
                    return true
                end
            end
            return false
        end
    end
end

