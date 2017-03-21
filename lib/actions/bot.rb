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
            headers = ['_blueprint','id','tiny_id','name','integrations','scheme','branch','coverage','with_tests']

            rows = []
            json["results"].each do |bot|
                blueprint = bot['configuration']['sourceControlBlueprint']
                blueprint_id = blueprint['DVTSourceControlWorkspaceBlueprintPrimaryRemoteRepositoryKey']
                branch = blueprint['DVTSourceControlWorkspaceBlueprintLocationsKey'][blueprint_id]
                rows << [
                    blueprint_id,
                    bot['_id'],
                    bot['tinyID'],
                    bot['name'],
                    bot['integration_counter'],
                    bot['configuration']['schemeName'],
                    branch ? branch["DVTSourceControlBranchIdentifierKey"] : '-',
                    bot['configuration']['codeCoveragePreference'],
                    bot['configuration']['performsTestAction']
                ]
            end
            table = Terminal::Table.new :title => title, :headings => headers, :rows => rows
            table.align_column(2, :right)
            table.align_column(3, :right)
            table.align_column(4, :right)
            table.align_column(5, :right)
            table.align_column(6, :right)
            puts table
        end

        def self.create
            url = "#{Xcodebot::Config.hostname}/bots"
            #this file is just a template, it's never updated
            file = File.read('models/create_bot.json')
            json = JSON.parse(file)

            #find . -name '*.xcscmblueprint' | xargs grep DVTSourceControlWorkspaceBlueprintPrimaryRemoteRepositoryKey | sed -e 's/".*" : "\(.*\)",/\1/'
            args = Hash[ARGV.map {|el| el.split ':'}]

            if !args.keys.include?('blueprint')
                puts "Please fill your Blueprint Id".red
                puts "Run the following `command` from your xcode project for having blueprint id :"
                puts "---"
                puts "find . -name '*.xcscmblueprint' | \\".italic.light_white
                puts "xargs grep DVTSourceControlWorkspaceBlueprintPrimaryRemoteRepositoryKey | \\".italic.light_white
                puts "sed -e 's/\".*\" : \"\\(.*\\)\",/\\1/'".italic.light_white
                puts "---"
                abort
            end

            abort "Parameter is missing : `name`".red if !args.keys.include?('name')
            abort "Parameter is missing : `schedule`".red if !args.keys.include?('schedule')
            abort "Parameter is missing : `clean` (0|1)".red if !args.keys.include?('clean')
            abort "Parameter is missing : `branch`".red if !args.keys.include?('branch')
            abort "Parameter is missing : `scheme`".red if !args.keys.include?('scheme')

            args.each do |key,value|
                case key
                when "blueprint"
                    puts "blueprint".blue
                when "name"
                    json["name"] = value
                when "schedule"
                    json["configuration"]["scheduleType"] = value
                when "clean"
                    json["configuration"]["builtFromClean"] = value
                when "branch"
                    puts "branch".blue
                when "scheme"
                    json["configuration"]["schemeName"] = value
                else
                    puts "Unknown parameter `#{key}`, `bin/xcodebot bots --create` for more info".yellow
                end
            end

            exit
            response = Xcodebot::Url.post_json(url,json)
            if response.kind_of? Net::HTTPSuccess
                puts "Bot #{id} has been successfully created".green
            else
                abort "Error while creating bot : #{response.code}, #{response.message}".red
            end
        end

        def self.delete(id)
            ARGV.each do |arg|
                url = "#{Xcodebot::Config.hostname}/bots/" + arg
                response = Xcodebot::Url.delete(url)
                if response.kind_of? Net::HTTPSuccess
                    puts "Bot #{arg} has been successfully deleted".green
                else
                    abort "Error while trying to delete bot #{arg} : #{response.code}, #{response.message}".red
                end
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
