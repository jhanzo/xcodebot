module Xcodebot
    STATUSES = {
        "canceled" => "Canceled".red,
        "trigger-error" => "Trigger error".red,
        "build-errors" => "Build error".red,
        "warnings" => "Warning".yellow
    }

    STEPS = {
        "completed" => "Completed".green,
        "pending" => "Pending".light_white,
        "checkout" => "Checkout".light_white,
        "uploading" => "Upload".light_blue,
        "before-triggers" => "Before triggers".light_white,
        "after-triggers" => "After triggers".light_white,
    }

    class Integration
        def self.run
            if ARGV.size > 0
                if (["--list","-l"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    list(ARGV[0])
                    return true
                end
                if (["--create","-c"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    return false if !ARGV[0]
                    create(ARGV[0])
                    return true
                end
                if (["--status","-s"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    #return false if !ARGV[0]
                    status
                    return true
                end
                if (["--cancel"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    return false if !ARGV[0]
                    cancel(ARGV[0])
                    return true
                end
                if (["--delete","--remove"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    return false if !ARGV[0]
                    delete(ARGV[0])
                    return true
                end
                if (["--delete-all","remove-all"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    delete_all
                    return true
                end
                if (["--logs"] & ARGV).size > 0
                    #remove argument config
                    ARGV.delete(ARGV.first)
                    return false if !ARGV[0]
                    logs(ARGV[0])
                    return true
                end
            end
            return false
        end

        # CRUD actions

        def self.list(bot_id)
            #if no arg provided, all integrations should be returned
            url = !ARGV[0] ?
                    "#{Xcodebot::Config.hostname}/integrations" :
                    "#{Xcodebot::Config.hostname}/bots/#{bot_id}/integrations"

            response = Xcodebot::Url.get(url)
            if !(response.kind_of? Net::HTTPSuccess)
                abort "Error while getting integrations for bot #{bot_id} : #{response.code}, #{response.message}".red
            end
            json = JSON.parse(response.body)

            title = "#{json["count"]} integrations found".italic
            headers = ['bot','scheme','tiny_id','number','step','result','start_date','duration']

            rows = []
            json["results"].each do |int|
                rows << [
                    "#{int['bot']['name']} (#{int['bot']['tinyID']})",
                    int['bot']['configuration']['schemeName'],
                    int['tinyID'],
                    int['number'],
                    !STEPS["#{int['currentStep']}"] ? int['currentStep'] : STEPS["#{int['currentStep']}"],
                    !STATUSES["#{int['result']}"] ? int['result'] : STATUSES["#{int['result']}"],
                    int['startedTime'] ? DateTime.parse(int['startedTime']).strftime("%m/%d/%Y %H:%M:%S").blue : "-",
                    int['duration']? Time.at(int['duration']).utc.strftime("%Hh %Mmin %Ssec").blue : "-"
                ]
            end
            table = Terminal::Table.new :title => title, :headings => headers, :rows => rows
            table.align_column(2, :right)
            table.align_column(3, :right)
            table.align_column(4, :right)
            table.align_column(5, :right)
            puts table
        end

        def self.create(bot_id)
            url = "#{Xcodebot::Config.hostname}/bots/#{bot_id}/integrations"

            response = Xcodebot::Url.post(url)
            if response.kind_of? Net::HTTPSuccess
                json = JSON.parse(response.body)
                puts "Integration ##{json['number']} has been created".green
                puts "Bot #{json['bot']['name']}, integration : #{json['tinyID']} (#{json['_id']})"

                if (["--wait"] & ARGV).size > 0
                    print "\nWait until integration ends...\n".blue
                    display_status(json['tinyID'])
                end
            else
                abort "Error while getting integration for bot #{bot_id} : #{response.code}, #{response.message}".red
            end
        end

        def self.cancel(id)
            url = "#{Xcodebot::Config.hostname}/integrations/#{id}/cancel"

            response = Xcodebot::Url.post(url)
            if response.kind_of? Net::HTTPSuccess
                puts "Integration #{id} successfully canceled".green
            else
                abort "Error while canceling integration #{id} : #{response.code}, #{response.message}".red
            end
        end

        def self.delete_all
            url = "#{Xcodebot::Config.hostname}/integrations"

            #get all integrations id
            response = Xcodebot::Url.get(url)
            if !(response.kind_of? Net::HTTPSuccess)
                abort "Error while deleting all integrations : #{response.code}, #{response.message}".red
            end
            json = JSON.parse(response.body)
            #for each id, remove integration from id
            json["results"].each do |int|
                delete(int["_id"])
            end
            puts "#{json["count"]} integrations successfully deleted".green
        end

        def self.delete(id)
            url = "#{Xcodebot::Config.hostname}/integrations/#{id}"

            response = Xcodebot::Url.delete(url)
            if response.kind_of? Net::HTTPSuccess
                puts "Integration #{id} successfully deleted".green
            else
                abort "Error while deleting integration #{id} : #{response.code}, #{response.message}".red
            end
        end

        def self.status
            spin_it 10
        end

        # helpers

        def self.spin_it(times)
          pinwheel = %w{| / - \\}
          times.times do
            print "\b" + pinwheel.rotate!.first
            sleep(0.5)
          end
        end

        def self.display_status(id)
            url = "#{Xcodebot::Config.hostname}/integrations/#{id}"

            last_step = ''
            step = ''
            while step != 'completed'
                response = Xcodebot::Url.get(url)
                json = JSON.parse(response.body)
                step = json['currentStep']
                result = json['result']
                last_step = step

                step_value = !STEPS["#{json['currentStep']}"] ? json['currentStep'] : STEPS["#{json['currentStep']}"]
                print "\n\b- Performing step: " + "#{step_value}".blue + "...  "
                pinwheel = %w{| / - \\}
                while last_step == step
                    print "\b" + pinwheel.rotate!.first
                    response = Xcodebot::Url.get(url)
                    json = JSON.parse(response.body)
                    step = json['currentStep']
                    sleep(0.25)
                end
                print "\b"
                print "OK\n".green

                sleep 1
            end
        end

        def self.logs(id)
            url = "#{Xcodebot::Config.hostname}/integrations/#{id}/assets"

            response = Xcodebot::Url.get(url)
            if response.kind_of? Net::HTTPSuccess
                puts response.body
            else
                abort "Error while getting logs about integration #{id} : #{response.code}, #{response.message}".red
            end
        end

        def get_status(id)
            url = "#{Xcodebot::Config.hostname}/integrations/#{id}"

            response = Xcodebot::Url.get(url)
            if response.kind_of? Net::HTTPSuccess
                json = JSON.parse(response.body)
                json['currentStep']
                json['result']
                return json['currentStep']
            end
        end
    end
end
