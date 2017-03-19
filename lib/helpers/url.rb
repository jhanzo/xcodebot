require "base64"

module Xcodebot
    class Url

        def self.generateToken
            if !ENV['XCODEBOT_EMAIL'] || !ENV['XCODEBOT_PASSWORD']
                abort "Both XCODEBOT_EMAIL and XCODEBOT_PASSWORD are required for this route".red
            end
            Base64.encode64("#{ENV['XCODEBOT_EMAIL']}:#{ENV['XCODEBOT_PASSWORD']}")
            return "bWFjc2VydmljZXM6MzdHaW5wcmE"
        end

        def self.display_url(url)
            puts "Xcode server API endpoint is : ".italic.light_white + "#{url}".green
            print "Testing reachability ... ".italic.light_white
            reachable = self.is_reachable(url)
            print "#{reachable}\n"
            abort if !reachable
        end

        def self.check_url(url)
            #check if URI is correct
            if !(url =~ URI::regexp)
                abort "`#{url}` is not a valid url, please fill a valid one, ex : https://127.0.0.1:20343/api".red
            end
            return url
        end

        def self.is_reachable(url)
            #check if URI is reachable
            begin
                res = self.get(url)
            rescue StandardError => e
                puts "KO".red
                abort "#{e.to_s}".red
            end
            return res.code == "200" ? "OK".green : "OK but #{res.code} : #{res.message}".yellow
        end

        #convenient URL method

        def self.get(url)
            uri = URI.parse(url)
            req = Net::HTTP::Get.new(uri)

            return Net::HTTP.start(
                uri.host,
                uri.port,
                :use_ssl => uri.scheme == 'https',
                :verify_mode => OpenSSL::SSL::VERIFY_NONE
            ) do |https|
                https.request(req)
            end
        end

        def self.delete(url)
            uri = URI.parse(url)
            req = Net::HTTP::Delete.new(uri)
            req.add_field("Authorization", "Basic #{generateToken}=")

            return Net::HTTP.start(
                uri.host,
                uri.port,
                :use_ssl => uri.scheme == 'https',
                :verify_mode => OpenSSL::SSL::VERIFY_NONE
            ) do |https|
                https.request(req)
            end
        end

        def self.post(url)
            uri = URI.parse(url)
            req = Net::HTTP::Post.new(uri)
            req.add_field("Authorization", "Basic #{generateToken}=")

            return Net::HTTP.start(
                uri.host,
                uri.port,
                :use_ssl => uri.scheme == 'https',
                :verify_mode => OpenSSL::SSL::VERIFY_NONE
            ) do |https|
                https.request(req)
            end
        end

    end
end
