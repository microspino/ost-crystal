require "spec"
require "../src/ost"

Ost.redis = Redis.new

Spec.before_each do
  Ost.redis.flushall
end
