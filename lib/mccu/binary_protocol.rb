require 'dalli'

module Mccu
  class BinaryProtocol
    def initialize(host, port='11211')
      @host = host
      @port = port
    end

    def client
      @client ||= Dalli::Client.new("#{@host}:#{@port}")
    end

    def delete(key)
      client.delete key
    end

    def flush_all
      client.flush_all
    end

    def close
      @client.close if @client
    end
  end
end
