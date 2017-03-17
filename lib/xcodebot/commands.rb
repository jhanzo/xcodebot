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
                c.syntax = 'xcodebot config [options]'
                c.description = 'Config xcode server api endpoint'
                c.example 'configure xcode bots', 'xcodebot config'
                c.option '--get-config', '-c', 'Display xcode server api endpoint'
                c.option '--address', '-a',  'Set address for xcode server api endpoint'
                c.option '--localhost', '--local', 'Use localhost api endpoint'
                c.action do |args, options|
                    #remove argument config
                    ARGV.delete("config") if ARGV.first == "config"
                    #display help for these cases
                    if !Xcodebot::Config.configure && ARGV.size == 0 && !options.size
                        command(:help).run
                        exit
                    end
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
