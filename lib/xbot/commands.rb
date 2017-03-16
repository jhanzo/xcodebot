require 'commander'
require 'colorize'
require 'rubygems'

module Xbot
    class CommandsGenerator
        include Commander::Methods

        def self.start
            if ARGV.size == 0
                puts "Help".italic
            end
            if (["--verbose","-v"] & ARGV).size > 0
                puts "Verbose mode enabled".yellow
            end

            self.new.run
        end

        def run
            program :name, 'xbot'
            program :version, Xbot::VERSION
            program :description, 'Manage xcode bots'

            command :bots do |c|
                c.syntax = 'xbot bots'
                c.description = 'Lists xcode bots'
                c.example 'lists xcode bots', 'xbot bots'
                c.action do |args, options|
                    say "xbot bots".blue
                end
            end

            command :integrations do |c|
                c.syntax = 'xbot integrations'
                c.description = 'Lists xcode integrations'
                c.example 'lists xcode integrations', 'xbot integrations'
                c.action do |args, options|
                    say "xbot integrations".blue
                end
            end

            command :issues do |c|
                c.syntax = 'xbot issues'
                c.description = 'Lists xcode issues'
                c.example 'lists xcode integration available', 'xbot issues'
                c.action do |args, options|
                    say "xbot integrations".blue
                end
            end

            default_command :help
            run!
        end
    end
end
