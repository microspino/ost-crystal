require "./spec_helper"
require "../ost"

describe Ost do
  it "stop processing a queue" do
    Ost[:events].push(1)
    Ost[:events].stop
    Ost[:events].each { }

    true
  end

  it "stop processing all queues" do
    Ost[:events].push(1)
    Ost[:people].push(1)

    Ost.stop
    Ost[:events].each { }
    Ost[:people].each { }

    true
  end
end