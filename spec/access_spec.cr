require "./spec_helper"
require "../ost"

describe "Access" do
  it "access to underlying key" do
    Ost[:events].key.to_s.should eq "ost:events"
  end

  it "access to queued items" do
    Ost[:events].push(1)

    Ost[:events].items.should eq ["1"]
  end

  it "access to queue size" do
    queue = Ost[:events]
    queue.size.should eq 0

    queue.push(1)
    queue.size.should eq 1

    queue.stop
    queue.each { }
    queue.size.should eq 0
  end
end