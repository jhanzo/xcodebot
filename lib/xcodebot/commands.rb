require 'commander'
require 'colorize'
require 'rubygems'
require_relative 'version'
require './lib/actions/bot'
require './lib/actions/integration'

module Xcodebot
    class CommandsGenerator
        include Commander::Methods

        def self.start
            self.new.run
        end

        def run
            spec = Gem::Specification::load("xcodebot.gemspec")
            program :name, 'xcodebot'
            program :version, Xcodebot::VERSION
            program :description, "#{spec.description}"
            program :help, 'Author', "#{spec.authors.first} <#{spec.email.first}>"
            program :help, 'GitHub', "#{spec.homepage}"
            program :help_formatter, :compact

            command :bots do |c|
                c.syntax = 'xcodebot bots'
                c.description = 'Lists xcode bots'
                c.example 'lists xcode bots', 'xcodebot bots'
                c.action do |args, options|
                    Xcodebot::Bot.new.run
                end
            end

            command :integrations do |c|
                c.syntax = 'xcodebot integrations'
                c.description = 'Lists xcode integrations'
                c.example 'lists xcode integrations', 'xcodebot integrations'
                c.action do |args, options|
                    Xcodebot::Integration.new.run
                end
            end

            command :info do |c|
                if ARGV.size == 0 || ( ["--help","-h"] & ARGV).size > 0
                    command(:help).run
                    print "---------------------------------------\n".green
                    print "Xcodebot v#{Xcodebot::VERSION}\n".italic.green
                    print "Status: ".italic.green + "Work in Progress".italic.yellow + "\n"
                    print "---------------------------------------\n".green
                end
            end

            default_command :help
            run!
        end
    end
end
