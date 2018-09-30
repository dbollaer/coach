require "coach/version"
require 'guard/cli'
require 'ruby_runner'
require 'yaml'
module Coach
  class Advice


    def initialize
      conf           = YAML::load_file(File.join(__dir__, '../config.yml'))
      @listOfActions = Array.new
      conf['actions'].each do |key, action|
      #  puts action.inspect
        action = Coach::Action.new action['command'], action['location']
        @listOfActions << action
      end
      puts @listOfActions.inspect

    end


    def run
      puts @listOfActions.inspect
      @listOfActions.each do |action|
        puts action.inspect
         action.run
      end

    end
  end


    class Action

      def initialize (command, location)
        @command  = command
        @location = location
      end


      def run
        mrr = RubyRunner.new

        stdout = mrr.execute_command_in_directory(
          @command,
          @location
        )
        puts "test"
        return stdout
      end
    end

  end

