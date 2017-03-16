require 'commander'

module Xcodebot
    class Integration
        include Commander::Methods

        def run
            command :info do |c|
                print "xcodebot integrations\n".green
            end

            default_command :info
            run!
        end
    end
end
