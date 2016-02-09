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

    def each_matched_key(pattern, &block)
      each_all_key do |item|
        if pattern === item[:key]
          yield item
        end
      end
    end

    def each_all_key(&block)
      flushed_at = start_time + oldest_live
      @conn[:text].each_all_key do |item|
        if item[:exptime] > flushed_at
          yield item
        end
      end
    end

    def stats_cachedump
      stats = {}
      @conn[:text].each_slab do |slab|
        stats[slab] = @conn[:text].stats_cachedump(slab)
      end
      stats
    end

    def stats_settings
      @conn[:binary].stats(:settings).values.first
    end

    def stats_items
      @conn[:binary].stats(:items).values.first
    end

    def stats_slabs
      @conn[:binary].stats(:slabs).values.first
    end

    def stats
      @conn[:binary].stats.values.first
    end

    def start_time
      _stats = stats
      _stats['time'].to_i - _stats['uptime'].to_i
    end

    def oldest_live
      stats_settings['oldest'].to_i
    end
  end
end
