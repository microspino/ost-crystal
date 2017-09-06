require "./spec_helper"
require "../ost"

describe "Connection" do
  it "inherits ost redis connection by default" do
    queue = Ost[:events]

    Ost.redis.url.should eq queue.redis.url
  end

  it "queue can define its own connection" do
    queue = Ost[:people]
    queue.redis = Redis.new(host: "localhost", port: 6379, database: 1)

    Ost.redis.url.should_not eq queue.redis.url
  end
end