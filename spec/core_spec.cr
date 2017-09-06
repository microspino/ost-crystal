require "./spec_helper"
require "../ost"

describe Ost do
  it "process items from the queue" do
    Ost[:events].push(1)

    results = [] of String | Int32

    Ost[:events].stop
    Ost[:events].each do |item|
      results << item
    end

    Ost[:events].items.should eq Array(String | Int32).new
    results.should eq ["1"]
  end
end