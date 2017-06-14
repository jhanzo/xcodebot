require 'net/http'
require 'json'
require_relative 'config'
require 'terminal-table'

module Xcodebot
    class Bot
        def self.run
            if ARGV.size > 0
                if (["--list-all"] & ARGV).size > 0
                    listAll
                    return true
                end
                if (["--list","-l"] & ARGV).size > 0
                    list
                    return true
                end
                if (["--get"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    return false if !ARGV[0]
                    get(ARGV[0])
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
                if (["--getId"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    return false if !ARGV[0]
		    get_id(ARGV[0])
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
          headers = ['tiny_id','name','scheme','branch','coverage','with_tests']

          rows = []
          json["results"].each do |bot|
              blueprint = bot['configuration']['sourceControlBlueprint']
              blueprint_id = blueprint['DVTSourceControlWorkspaceBlueprintPrimaryRemoteRepositoryKey']
              branch = blueprint['DVTSourceControlWorkspaceBlueprintLocationsKey'][blueprint_id]
              puts "- Bot `#{bot['name']}` (#{bot['tinyID']}) for `#{bot['configuration']['schemeName']}` on `#{branch ? branch["DVTSourceControlBranchIdentifierKey"] : 'unknown'}`"
          end
        end

        def self.listAll
            url = "#{Xcodebot::Config.hostname}/bots"

            response = Xcodebot::Url.get(url)
            if !(response.kind_of? Net::HTTPSuccess)
                abort "Error while getting bots : #{response.code}, #{response.message}".red
            end
            json = JSON.parse(response.body)

            title = "#{json["count"]} bots found ".italic
            headers = ['id','tiny_id','name','integrations','scheme','branch','coverage','with_tests']

            rows = []
            json["results"].each do |bot|
                blueprint = bot['configuration']['sourceControlBlueprint']
                blueprint_id = blueprint['DVTSourceControlWorkspaceBlueprintPrimaryRemoteRepositoryKey']
                branch = blueprint['DVTSourceControlWorkspaceBlueprintLocationsKey'][blueprint_id]
                rows << [
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

        def self.get(id)
            url = "#{Xcodebot::Config.hostname}/bots/#{id}"

            response = Xcodebot::Url.get(url)
            if response.kind_of? Net::HTTPSuccess
                json = JSON.parse(response.body)
                blueprint = json['configuration']['sourceControlBlueprint']
                blueprint_id = blueprint['DVTSourceControlWorkspaceBlueprintPrimaryRemoteRepositoryKey']
                branch = blueprint['DVTSourceControlWorkspaceBlueprintLocationsKey'][blueprint_id]

                print "\nSuccessfully got bot #{json['tinyID']} (#{id})\n".green
                print "#{json['name']}".light_white + " has #{json['integration_counter']} integrations\n"
                if branch
                    print "Checkout branch " + "#{branch["DVTSourceControlBranchIdentifierKey"]}".light_white + " and "
                end
                print "built for scheme " + "#{json['configuration']['schemeName']}".light_white + "\n"
                print "\nBlueprint id : " + "#{blueprint_id}\n".light_white
            else
                abort "Error while getting bot #{id}: #{response.code}, #{response.message}".red
            end
        end

        def self.create
            url = "#{Xcodebot::Config.hostname}/bots"

            #get arguments
            args = Hash[ARGV.map {|el| el.split(':',2)}]

            abort "Parameter is missing : `json`".red if !args.keys.include?('json')
            abort "Parameter is missing : `scheme`".red if !args.keys.include?('scheme')
            abort "Parameter is missing : `name`".red if !args.keys.include?('name')
            abort "Parameter is missing : `branch`".red if !args.keys.include?('branch')
            abort "Please fill a valid model json file".red if !File.file?(args['json'])

            file = File.read(args['json'])

            replace = file.gsub(/(<NAME>|<SCHEME>|<BRANCH>)/) do |match|
                case match
                when '<NAME>' then args['name']
                when '<SCHEME>' then args['scheme']
                when '<BRANCH>' then args['branch']
                end
            end

            response = Xcodebot::Url.post_json(url,JSON.parse(replace).to_json)
            if response.kind_of? Net::HTTPSuccess
                puts JSON.parse(response.body)["_id"]
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

	def self.get_id(name)
	   url = "#{Xcodebot::Config.hostname}/bots"
	   response = Xcodebot::Url.get(url)
	   if !(response.kind_of? Net::HTTPSuccess)
	       abort "Error while getting bots : #{response.code}, #{response.message}".red
	   end
	   json = JSON.parse(response.body)
	   puts json["results"].find { |r| r["name"] == name }["_id"]
	end
    end
end
