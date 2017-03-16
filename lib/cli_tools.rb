require './lib/xbot/version'
require './lib/xbot/commands'

module Xbot
# Manage command and ARGV
    class CLITools
        def self.start
            Xbot::CommandsGenerator.start
        end
    end
end
