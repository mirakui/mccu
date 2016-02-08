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

    def purge_matched(regex)
      matched_count = 0
      @conn[:text].each_all_key do |key|
        if key =~ regex
          matched_count += 1
          @conn[:binary].delete key
        end
      end
      matched_count
    end

    def list_matched(regex)
      matched_keys = []
      @conn[:text].each_all_key do |key|
        if key =~ regex
          matched_keys << key
        end
      end
      matched_keys
    end
  end
end
