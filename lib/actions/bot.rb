require 'commander'

module Xbot
    class Bot
        include Commander::Methods

        def run
            command :info do |c|
                print "xbot bots\n".green
            end

            default_command :info
            run!
        end
    end
end
