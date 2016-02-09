require 'thor'
require 'mccu/client'
require 'json'

module Mccu
  class Cli < Thor
    desc 'purge', 'purge items'
    option :key, type: :string
    option :prefix, type: :string
    option :regex, type: :string
    option :all, type: :boolean
    def purge
      connect do |client|
        if options[:all]
          client.purge_all
          puts "purged all items"
        elsif options[:key]
          count = client.purge options[:key]
          puts "purged #{count} items"
        else
          pattern = make_pattern
          count = client.purge_matched pattern
          puts "purged #{count} items"
        end
      end
    end

    desc 'list', 'list keys'
    option :prefix, type: :string
    option :regex, type: :string
    def list
      connect do |client|
        pattern = make_pattern
        if pattern
          client.each_matched_key(pattern) do |key|
            puts key[:key]
          end
        else
          client.each_all_key do |key|
            puts key[:key]
          end
        end
      end
    end

    desc 'stats', 'show stats'
    def stats(op=nil)
      connect do |client|
        stats = case op
                when 'cachedump'
                  client.stats_cachedump
                when 'settings'
                  client.stats_settings
                when 'items'
                  client.stats_items
                when 'slabs'
                  client.stats_slabs
                when nil
                  client.stats
                else
                  abort "unknown stats operator: #{op}"
                end
        puts stats.to_json
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
        if options[:prefix]
          Regexp.new "^#{Regexp.escape options[:prefix]}"
        elsif options[:regex]
          Regexp.new options[:regex]
        end
      end
    end
  end
end
