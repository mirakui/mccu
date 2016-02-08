require 'thor'
require 'mccu/client'

module Mccu
  class Cli < Thor
    desc 'purge', 'purge items'
    option :key, type: :string
    option :prefix, type: :string
    option :regex, type: :string
    def purge
      pattern = make_pattern
      connect do |client|
        count = client.purge_matched pattern
        puts "purged #{count} items"
      end
    end

    desc 'list', 'list keys'
    option :key, type: :string
    option :prefix, type: :string
    option :regex, type: :string
    def list_keys
      pattern = make_pattern
      connect do |client|
        client.list_matched(pattern).each do |key|
          puts key
        end
      end
    end

    no_tasks do
      def connect
        client = Mccu::Client.new 'localhost'
        begin
          yield client
        ensure
          client.close
        end
      end

      def make_pattern
        if options[:key]
          options[:key]
        elsif options[:regex]
          Regexp.new "^#{options[:regex]}"
        elsif options[:prefix]
          Regexp.new options[:prefix]
        end
      end
    end
  end
end
