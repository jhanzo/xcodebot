require 'net/http'
require 'json'
require_relative 'config'
require 'terminal-table'

module Xcodebot
    class Bot
        def self.run
            if ARGV.size > 0
                if (["--list","-l"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    list
                    return true
                end
                if (["--get","-g"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    return false if !ARGV[0]
                    get(ARGV[0])
                    return true
                end
                if (["--create","-c"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    return false if !ARGV[0]
                    create
                    return true
                end
                if (["--delete","-r"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    return false if !ARGV[0]
                    delete(ARGV[0])
                    return true
                end
                if (["--duplicate","-d"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    return false if !ARGV[0]
                    duplicate(ARGV[0])
                    return true
                end
            end
            return false
        end

        # CRUD actions

        def self.list
            url = Xcodebot::Config.hostname + "/bots"

            response = Xcodebot::Url.get(url)
            if !(response.kind_of? Net::HTTPSuccess)
                abort "Error while getting bots : #{response.code}, #{response.message}"
            end
            json = JSON.parse(result.body)

            title = "#{json["count"]} bots found from #{url}".italic
            headers = ['id','name','integrations','scheme','with_coverage','with_tests']

            rows = []
            json["results"].each do |bot|
                rows << [
                    bot['_id'],
                    bot['name'],
                    bot['integration_counter'],
                    bot['configuration']['schemeName'],
                    bot['configuration']['codeCoveragePreference'],
                    bot['configuration']['performsTestAction']
                ]
            end
            table = Terminal::Table.new :title => title, :headings => headers, :rows => rows
            table.align_column(2, :right)
            table.align_column(3, :right)
            table.align_column(4, :right)
            table.align_column(5, :right)
            puts table
        end

        def self.get(id)
            url = Xcodebot::Config.hostname + "/bots/" + id
            response = Xcodebot::Url.get(url)

            puts response

            if !(response.kind_of? Net::HTTPSuccess)
                abort "Error while getting bot #{id} : #{response.code}, #{response.message}"
            end
        end

        def self.create

        end

        def self.delete(id)
            url = Xcodebot::Config.hostname + "/bots/" + id
            response = Xcodebot::Url.delete(url)
            if response.kind_of? Net::HTTPSuccess
                puts "Bot #{id} has been successfully deleted".green
            else
                abort "Error while trying to delete bot #{id} : #{response.code}, #{response.message}".red
            end
        end

        def self.duplicate(id)
            url = Xcodebot::Config.hostname + "/bots/" + id + "/duplicate"
            response = Xcodebot::Url.post(url)
            if response.kind_of? Net::HTTPSuccess
                puts "Bot #{id} has been successfully duplicated".green
            else
                abort "Error while trying to duplicating bot #{id} : #{response.code}, #{response.message}".red
            end
        end
    end
end
