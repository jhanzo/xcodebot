require 'commander'
require 'colorize'
require 'rubygems'
require_relative 'version'

module Xbot
    class CommandsGenerator
        include Commander::Methods

        def self.start
            self.new.run
        end

        def run
            spec = Gem::Specification::load("xbot.gemspec")
            program :name, 'xbot'
            program :version, Xbot::VERSION
            program :description, "#{spec.description}"
            program :help, 'Author', "#{spec.authors.first} <#{spec.email.first}>"
            program :help, 'GitHub', "#{spec.homepage}"
            program :help_formatter, :compact

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

            command :info do |c|
                command(:help).run
                print "---------------------------------------\n".green
                print "Xbot v#{Xbot::VERSION}\n".italic.green
                print "Status: ".italic.green + "Work in Progress".italic.yellow + "\n"
                print "---------------------------------------\n".green
            end

            default_command :help
            run!
        end
    end
end
