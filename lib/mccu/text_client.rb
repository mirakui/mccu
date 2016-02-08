require 'net/telnet'

module Mccu
  class TextClient
    TIMEOUT = 3

    def initialize(host, port=11211)
      @host = host
      @port = port
    end

    def telnet
      @telnet ||= Net::Telnet.new 'Host' => @host, 'Port' => @port
    end

    def cmd(str, match:/^(END|ERROR|OK)/)
      result = ''
      telnet.cmd('String' => str, 'Match' => match, 'Timeout' => TIMEOUT) {|c| result += c }
      result
    rescue Net::ReadTimeout => e
      raise "Timed out while waiting for matching #{match}, result was: #{result.inspect}"
    end

    def set(key, value, compress:0, expire:0)
      cmd "set #{key} #{compress} #{expire} #{value.length}\n#{value}", match: /^STORED$/
    end

    def stats_items
      stats_items = cmd 'stats items'
      slabs = {}
      stats_items.each_line do |line|
        if m = /^STAT items:(?<slab>\d+):(?<attr>\w+) (?<value>\d+)$/.match(line)
          slab, attr, value = m['slab'].to_i, m['attr'], m['value'].to_i
          slabs[slab] ||= {}
          slabs[slab][attr] = value
        end
      end
      slabs
    end

    def stats_cachedump(slab)
      cachedump = cmd "stats cachedump #{slab} 0"
      items = {}
      cachedump.each_line do |line|
        if m = /^ITEM (?<key>.+) \[(?<bytes>\d+) b; (?<time>\d+) s\]$/.match(line)
          key, bytes, time = m['key'], m['bytes'].to_i, m['time'].to_i
          items[key] ||= {}
          items[key] = { byets: bytes, time: time }
        end
      end
      items
    end
  end
end
