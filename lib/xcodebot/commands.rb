require 'commander'
require 'colorize'
require 'rubygems'
require './lib/xcodebot/version'
require './lib/actions/bot'
require './lib/actions/integration'
require './lib/helpers/config'

module Xcodebot
    class CommandsGenerator
        include Commander::Methods

        def self.start
            if !ARGV.include?("--local")
                #abort "Please fill XCODEBOT_HOST".red unless ENV['XCODEBOT_HOST']
                #abort "Please fill XCODEBOT_USERNAME".red unless ENV['XCODEBOT_USERNAME']
                #abort "Please fill XCODEBOT_PASSWORD".red unless ENV['XCODEBOT_PASSWORD']
            end

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

            command :config do |c|
                c.syntax = 'xcodebot config'
                c.description = 'Config xcode server api endpoint'
                c.example 'configure xcode bots', 'xcodebot config'
                c.action do |args, options|
                    Xcodebot::Config.first_time_config
                end
            end

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
