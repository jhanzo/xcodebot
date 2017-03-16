require 'commander'

module Xcodebot
    class Bot
        include Commander::Methods

        def run
            command :info do |c|
                print "xcodebot bots\n".green
            end

            default_command :info
            run!
        end
    end
end
