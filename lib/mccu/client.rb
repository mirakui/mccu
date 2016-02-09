require 'mccu/text_protocol'
require 'mccu/binary_protocol'

module Mccu
  class Client
    def initialize(host, port='11211')
      @host = host
      @port = port
      @conn = {
        text:   TextProtocol.new(@host, @port),
        binary: BinaryProtocol.new(@host, @port),
      }
    end

    def close
      @conn.each_value do |conn|
        conn.close
      end
    end

    def purge(key)
      result = @conn[:binary].delete key
      result ? 1 : 0
    end

    def purge_all
      @conn[:binary].flush_all
    end

    def purge_matched(pattern)
      matched_count = 0
      each_matched_key(pattern) do |key|
        matched_count += 1
        @conn[:binary].delete key
      end
      matched_count
    end

    def list_matched(pattern)
      matched_keys = []
      each_matched_key(pattern) do |key|
        matched_keys << key
      end
      matched_keys
    end

    def stats_cachedump
      stats = {}
      @conn[:text].each_slab do |slab|
        stats.merge! @conn[:text].stats_cachedump(slab)
      end
      stats
    end

    def each_matched_key(pattern, &block)
      each_all_key do |key|
        if pattern === key
          yield key
        end
      end
    end

    def each_all_key(&block)
      @conn[:text].each_all_key &block
    end
  end
end
