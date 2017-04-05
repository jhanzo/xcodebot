require 'commander'
require 'colorize'
require 'rubygems'
require 'xcodebot/version'
require 'actions/bot'
require 'actions/integration'
require 'actions/config'

module Xcodebot
    class CommandsGenerator
        include Commander::Methods

        def check_envvar
            #warning about xcodebot env var
            if !ENV['XCODEBOT_LOGIN'] || !ENV['XCODEBOT_PASSWORD']
                puts "XCODEBOT_LOGIN and XCODEBOT_PASSWORD are missing in ENV VARs".yellow
            end
        end

        def self.start
            self.new.run
        end

        def run
            program :name, Xcodebot::NAME
            program :version, Xcodebot::VERSION
            program :description, Xcodebot::DESCRIPTION
            program :help, 'GitHub', Xcodebot::GITHUB
            program :help_formatter, :compact

            command :config do |c|
                c.syntax = 'xcodebot config [options]'
                c.description = 'Configure xcode server'
                c.example 'configure xcode bots', 'xcodebot config'
                c.option '--list', '-l', 'Display xcode server api endpoint'
                c.option '--address', '-a',  'Set address for xcode server api endpoint'
                c.option '--localhost', '--local', 'Use localhost api endpoint'
                c.action do |args, options|
                    #remove argument config
                    ARGV.delete("config") if ARGV.first == "config"
                    check_envvar unless ARGV.size == 0 && !options.size
                    #display help for these cases
                    if !Xcodebot::Config.run && ARGV.size == 0 && !options.size
                        command(:help).run
                        exit
                    end
                end
            end

            command :bots do |c|
                c.syntax = 'xcodebot bots [options]'
                c.description = 'Manage xcode bots (CRUD)'
                c.example 'manage xcode bots', 'xcodebot bots'
                c.option '--list', '-l', 'List all bots'
                c.option '--get', 'Get bot info by <id>'
                c.option '--stats', '-s', 'Stats for bot <id>'
                c.option '--create', '-c', 'Create a new bot with params <KEY>:<VALUE>'
                c.option '--duplicate', '-d', 'Duplicate bot <id>'
                c.option '--delete', '--remove', 'Remove one or several bot <id1> <id2> <...>'
                c.action do |args, options|
                    #remove argument config
                    ARGV.delete("bots") if ARGV.first == "bots"
                    #display help for these cases
                    if !Xcodebot::Bot.run && ARGV.size == 0 && !options.size
                        command(:help).run
                        exit
                    end
                end
            end

            command :integrations do |c|
                c.syntax = 'xcodebot integrations'
                c.description = 'Manage xcode integrations (CRUD)'
                c.example 'list xcode integrations', 'xcodebot integrations'
                c.option '--list', '-l', 'List integrations for a bot <id>'
                c.option '--create', '-c', 'Create a new integration for a bot <id>'
                c.option '--cancel', 'Cancel an integration <id>'
                c.option '--status', '-s', 'Status of an integration <id>'
                c.option '--logs', 'Get logs from an integration <id>'
                c.option '--delete', '--remove', 'Remove integration from <id>'
                c.option '--delete-all', '--remove-all', 'Remove all integrations'
                c.option '--wait', '-w', 'Wait until integration <id> ends'
                c.action do |args, options|
                    #remove argument config
                    ARGV.delete("integrations") if ARGV.first == "integrations"
                    #display help for these cases
                    if !Xcodebot::Integration.run && ARGV.size == 0 && !options.size
                        command(:help).run
                        exit
                    end
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
