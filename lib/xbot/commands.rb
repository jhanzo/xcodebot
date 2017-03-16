require 'commander'
require 'colorize'
require 'rubygems'

module Xbot
    class CommandsGenerator
        include Commander::Methods

        def self.start
            if ARGV.size == 0
                spec = Gem::Specification::load("xbot.gemspec")
                print "\n#{spec.description}\n\n".italic
            end

            self.new.run
        end

        def run
            program :name, 'xbot'
            program :version, Xbot::VERSION
            program :description, 'Manage xcode bots easier'
            program :help, 'Author', 'J2sHnz <jessy.hanzo@gmail.com>'

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

            default_command :help
            run!
        end
    end
end
