require 'yaml'
require 'uri'
require 'net/http'
require 'openssl'
require './lib/helpers/url.rb'

module Xcodebot
    class Config

        def self.localhost
            yml = YAML.load_file('config.yml')
            return "#{yml['localhost']['protocol']}://#{yml['localhost']['address']}:#{yml['localhost']['port']}/#{yml['localhost']['endpoint']}"
        end

        def self.hostname
            yml = YAML.load_file('config.yml')
            return "#{yml['server']['protocol']}://#{yml['server']['address']}:#{yml['server']['port']}/#{yml['server']['endpoint']}"
        end

        def self.set_url_from_config_file(url)
            #parse url into required properties
            url_string = url.dup
            uri = URI.parse(url_string)

            config = YAML.load_file('config.yml')
            config['server']['protocol'] = uri.scheme
            config['server']['address'] = uri.host
            config['server']['port'] = uri.port
            config['server']['endpoint'] = url_string.sub!("#{uri.scheme}://#{uri.host}:#{uri.port}/","")

            File.open('config.yml','w') do |f|
               f.write config.to_yaml
            end

            return uri.to_s
        end

        def self.run
            #if arguments provided
            if ARGV.size > 0
                if (["--list","-l"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    Xcodebot::Url.display_url(hostname)
                    return true
                end
                if (["--localhost","--local"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    self.set_url_from_config_file(localhost)
                    Xcodebot::Url.display_url(localhost)
                    return true
                end
                if (["--address","-a"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    #return if no parameter provided
                    return false if ARGV.size == 0
                    Xcodebot::Url.display_url(self.set_url_from_config_file(Xcodebot::Url.check_url(ARGV[0])))
                    return true
                end
            end
            return false
        end
    end
end
