require 'yaml'
require 'uri'
require 'net/http'
require 'openssl'

module Xcodebot
    class Config
        yml = YAML.load_file('config.yml')
        LOCALHOST="#{yml['localhost']['protocol']}://#{yml['localhost']['address']}:#{yml['localhost']['port']}/#{yml['localhost']['endpoint']}"
        HOSTNAME="#{yml['server']['protocol']}://#{yml['server']['address']}:#{yml['server']['port']}/#{yml['server']['endpoint']}"

        def self.url_from_config_file(url)
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

        def self.is_reachable(url)
            #check if URI is reachable
            begin
                uri = URI.parse(url)
                req = Net::HTTP::Get.new(uri)

                res = Net::HTTP.start(
                        uri.host, uri.port,
                        :use_ssl => uri.scheme == 'https',
                        :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |https|
                  https.request(req)
                end
                return res.code == "200" ? "reachable".green : "#{res.code} : #{res.message}".yellow
            rescue
                return "unreachable".red
            end
        end

        def self.check_url(url)
            #check if URI is correct
            if !(url =~ URI::regexp)
                abort "`#{url}` is not a valid url, please fill a valid one, ex : https://127.0.0.1:20343/api".red
            end
            return url
        end

        def self.configure
            #if arguments provided
            if ARGV.size > 0
                if (["--get-config","-c"] & ARGV).size > 0
                    puts "Xcode server api endpoint is : ".italic.light_white + "#{self::HOSTNAME}".green
                    print "Testing reachability ... ".italic.light_white
                    reachable = self.is_reachable(self::HOSTNAME)
                    print "#{reachable}\n"
                    abort if !reachable
                    return true
                end
                if (["--localhost","--local"] & ARGV).size > 0
                    self.url_from_config_file(self::LOCALHOST)
                    puts "Set xcode server api endpoint to : ".italic.light_white + "#{self::LOCALHOST}".green
                    return true
                end
                if (["--adress","-a"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete("--address") if ARGV.first == "--address"
                    ARGV.delete("-a") if ARGV.first == "-a"
                    #return if no parameter provided
                    return false if ARGV.size == 0
                    puts "Set xcode server api endpoint to : " + "#{self.url_from_config_file(self.check_url(ARGV[0]))}".green
                end
            end
            return false
        end
    end
end
