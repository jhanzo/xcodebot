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
                if (["--stats","-s"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    return false if !ARGV[0]
                    get_status(ARGV[0])
                    return true
                end
                if (["--create","-c"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    return false if !ARGV[0]
                    create
                    return true
                end
                if (["--delete","--remove"] & ARGV).size > 0
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
            url = "#{Xcodebot::Config.hostname}/bots"

            response = Xcodebot::Url.get(url)
            if !(response.kind_of? Net::HTTPSuccess)
                abort "Error while getting bots : #{response.code}, #{response.message}".red
            end
            json = JSON.parse(response.body)

            title = "#{json["count"]} bots found ".italic
            headers = ['id','tiny_id','name','integrations','scheme','with_coverage','with_tests']

            rows = []
            json["results"].each do |bot|
                rows << [
                    bot['_id'],
                    bot['tinyID'],
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

        def self.create
            url = "#{Xcodebot::Config.hostname}/bots"
            #this file is just a template, it's never updated
            file = File.read('models/create_bot.json')
            json = JSON.parse(file)

            ARGV.each |arg|
                #check if parameter is correctly normalized
                param = arg.split(/:/)
                if param.size == 2
                    case param.first
                    when "schedule"
                    when "clean"
                    when "branch"
                    when "scheme"
                    else
                        puts "Unknown parameter `#{param.first}`, `bin/xcodebot bots --create` for more info".red
                    end
                end
            end

            response = Xcodebot::Url.post_json(url,json)
            if response.kind_of? Net::HTTPSuccess
                puts "Bot #{id} has been successfully created".green
            else
                abort "Error while creating bot : #{response.code}, #{response.message}".red
            end
        end

        def self.delete(id)
            url = "#{Xcodebot::Config.hostname}/bots/" + id
            response = Xcodebot::Url.delete(url)
            if response.kind_of? Net::HTTPSuccess
                puts "Bot #{id} has been successfully deleted".green
            else
                abort "Error while trying to delete bot #{id} : #{response.code}, #{response.message}".red
            end
        end

        def self.duplicate(id)
            url = "#{Xcodebot::Config.hostname}/bots/#{id}/duplicate"
            response = Xcodebot::Url.post(url)
            if response.kind_of? Net::HTTPSuccess
                puts "Bot #{id} has been successfully duplicated".green
            else
                abort "Error while trying to duplicating bot #{id} : #{response.code}, #{response.message}".red
            end
        end

        def self.get_status(id)
            url = "#{Xcodebot::Config.hostname}/bots/#{id}/stats"

            response = Xcodebot::Url.get(url)
            if !(response.kind_of? Net::HTTPSuccess)
                abort "Error while getting bots : #{response.code}, #{response.message}".red
            end
            json = JSON.parse(response.body)

            title = "Stats information about #{id}".italic
            headers = ['Title','Value']

            rows = []
            rows << ['integrations', json['numberOfIntegrations']]
            rows << ['commits', json['numberOfCommits']]

            table = Terminal::Table.new :title => title, :headings => headers, :rows => rows
            table.align_column(1, :right)
            puts table
        end
    end
end
