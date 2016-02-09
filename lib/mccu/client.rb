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
      @conn[:text].each_all_key do |key|
        if pattern === key
          yield key
        end
      end
    end
  end
end
