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
                    return false if !ARGV[1]
                    get(ARGV[1])
                    return true
                end
                if (["--create","-c"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    return false if !ARGV[1]
                    create
                    return true
                end
                if (["--delete","-r"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    return false if !ARGV[1]
                    delete(ARGV[1])
                    return true
                end
                if (["--duplicate","-d"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    return false if !ARGV[1]
                    duplicate(ARGV[1])
                    return true
                end
            end
            return false
        end

        # CRUD actions

        def self.list
            url = Xcodebot::Config.hostname + "/bots"

            result = Xcodebot::Url.get(url)
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
            Xcodebot::Url.get(url)
        end

        def self.create

        end

        def self.delete(id)
            url = Xcodebot::Config.hostname + "/bots/" + id
            Xcodebot::Url.delete(url)
        end

        def self.duplicate(id)
            url = Xcodebot::Config.hostname + "/bots/" + id + "/duplicate"
            puts Xcodebot::Url.post(url)
        end
    end
end
