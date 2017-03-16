require 'rconfig'
require 'highline'
require 'uri'
require "net/http"

RConfig.load_paths = ["."]

module Xcodebot
    class Config
        HOSTNAME="#{RConfig.config.server.protocol}://#{RConfig.config.server.address}:#{RConfig.config.server.port}/#{RConfig.config.server.endpoint}"

        def self.url_config
            cli = HighLine.new
            api_endpoint = ""
            #check if URI is correct
            while !(api_endpoint =~ URI::regexp)
                api_endpoint = cli.ask "Please fill a valid api endpoint, ex : https://127.0.0.1:20343/api\n"
            end
            #check if URI is reachable
            url = URI.parse(api_endpoint)
            req = Net::HTTP.new(url.host, url.port)
            req.use_ssl = url
            res = req.request_head(url.path)
            if res.code != "200"
                confirm_url = cli.ask "#{api_endpoint} is not reachable for now, do you confirm it ? [Y|n]\n"
                if confirm_url == 'n'
                    self.url_config()
                end
            end
            #save api endpoint to config file
            #...
        end

        def self.first_time_config
            cli = HighLine.new
            print "xcodebot should be configured\n".italic.light_white

            default_endpoint = cli.ask "Use default xcode server api endpoint [#{self::HOSTNAME}] ? [Y|n]"
            if default_endpoint == 'n'
                print "Let's configuring your environment...\n".italic.light_white

                self.url_config()

            else
                puts "#{self::HOSTNAME}".yellow
                print "Ok ! Now we can work together, please run xcodebot --help for any help\n".italic.light_white
            end

            exit
        end
    end
end
