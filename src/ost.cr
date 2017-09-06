require "nido"
require "redis"

module Ost
  TIMEOUT = ENV["OST_TIMEOUT"]? || "2"

  class Queue
    include Enumerable(String|Int32)
    
    @@redis = Redis.new
    
    getter :key
    getter :backup
    
    @key : Nido
    @backup : Nido
    
    def initialize(name)
      @key = Nido.new(:ost)[name]
      @backup = @key[System.hostname][Process.pid]
      @stopping = false
    end

    def push(value)
      redis.lpush(@key, value)
    end

    def each
      loop do
        item = redis.brpoplpush(@key, @backup, TIMEOUT)

        if item
          yield item
          redis.lpop(@backup)
        end

        break if @stopping
      end
    end

    def stop
      @stopping = true
    end

    def items
      redis.lrange(@key, 0, -1)
    end

    # alias << push
    # alias pop each

    def size
      redis.llen(@key)
    end

    def redis
      @@redis
    end

    def redis=(redis)
      @@redis = redis
    end
  end

  @@queues = Hash(String | Symbol, Queue).new do |hash, key|
    hash[key] = Queue.new(key)
  end

  def self.[](queue)
    @@queues[queue]
  end

  def self.stop
    @@queues.each { |_, queue| queue.stop }
  end

  def self.redis
    @@redis ||= Redis.new
  end

  def self.redis=(redis)
    @@redis = redis
  end
end
