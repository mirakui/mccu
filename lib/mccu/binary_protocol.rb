require 'mccu'
require 'dalli'

module Mccu
  class BinaryProtocol
    def initialize(host, port='11211')
      @host = host
      @port = port
    end

    def client
      @client ||= begin
                    c = Dalli::Client.new("#{@host}:#{@port}")
                    c.alive!
                    c
                  rescue Dalli::RingError
                    raise Mccu::ConnectionError, "Cannot connect to #{@host}:#{@port}"
                  end
    end

    def delete(key)
      client.delete key
    end

    def flush_all
      client.flush_all
    end

    def stats(*args)
      client.stats(*args)
    end

    def close
      @client.close if @client
    end
  end
end
