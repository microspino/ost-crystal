require "./spec_helper"
require "../ost"

describe "Backup" do
  it "returns backup key" do
    hostname = System.hostname
    pid = Process.pid

    Ost[:events].backup.to_s.should eq "ost:events:#{hostname}:#{pid}"
  end

  it "maintains a backup queue for when worker dies" do
    queue = Ost[:events]

    queue.push(1)

    queue.redis.llen(queue.backup).should eq 0

    begin
      queue.stop
      queue.each { |item| raise "some error" }
    rescue
    end

    queue.redis.lrange(queue.backup, 0, -1).should eq ["1"]
  end

  it "cleans up the backup queue on success" do
    queue = Ost[:events]
    queue.push(1)

    queue.stop
    queue.each do |item|
      queue.redis.lrange(queue.backup, 0, -1).should eq [item]
    end

    queue.redis.lrange(queue.backup, 0, -1).should eq Array(String | Int32).new
  end
end