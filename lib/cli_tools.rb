require 'xcodebot/commands'

module Xcodebot
# Manage command and ARGV
    class CLITools
        def self.start
            Xcodebot::CommandsGenerator.start
        end
    end
end
