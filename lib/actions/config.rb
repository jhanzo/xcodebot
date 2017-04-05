require 'yaml'
require 'uri'
require 'net/http'
require 'openssl'
require 'helpers/url.rb'

module Xcodebot
    class Config

        def self.localhost
            ENV['XCODEBOT_SERVER'] = "https://127.0.0.1:20343/api"
	    return ENV['XCODEBOT_SERVER']
        end

        def self.run
            #if arguments provided
            if ARGV.size > 0
                if (["--list","-l"] & ARGV).size > 0
		    abort "Please fill env var XCODEBOT_SERVER".red if !ENV['XCODEBOT_SERVER']
                    Xcodebot::Url.display_url(ENV['XCODEBOT_SERVER'])
                    return true
                end
                if (["--localhost","--local"] & ARGV).size > 0
                    Xcodebot::Url.display_url(localhost)
                    return true
                end
                if (["--address","-a"] & ARGV).size > 0
		    #remove argument config
                    ARGV.delete(ARGV.first)
                    url = ARGV[0] ? ARGV[0] : ENV['XCODEBOT_SERVER']
		    abort "Please fill a parameter or env var XCODEBOT_SERVER".red if !url
		    Xcodebot::Url.display_url(Xcodebot::Url.check_url(ARGV[0]))
                    return true
                end
            end
            return false
        end
    end
end
