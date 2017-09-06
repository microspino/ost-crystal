Ost (ported to crystal lang.)
===

**ALPHA (the port is almost completed and tested but not production ready)**

Redis based queues and workers.

[Original Ruby project from @soveran](https://github.com/soveran/ost)

Description
-----------

**Ost** makes it easy to enqueue object ids and process them with
workers.

Say you want to process video uploads. In your application you will
have something like this:


    Ost[:videos_to_process].push(@video.id)


Then, you will have a worker that will look like this:


    require "ost"

    Ost[:videos_to_process].each do |id|
      # Do something with it!
    end


Usage
-----

Ost uses Redis. To connect to
a Redis database, you will need to set an instance of `Redis`, with a URL
of the form `redis://:<passwd>@<host>:<port>/<db>`.

You can customize the connection by calling `Ost.redis=`:

    require "ost"

    Ost.redis = Redis.new("redis://127.0.0.1:6379")

Then you only need to refer to a queue for it to pop into existence:

    require "ost"

    Ost.redis = Redis.new("redis://127.0.0.1:6379")

    Ost[:rss_feeds] << @feed.id

Ost defaults to a Redis connection to `redis://127.0.0.1:6379`. The example
above could be rewritten as:

    require "ost"

    Ost[:rss_feeds] << @feed.id

A worker is a Crystal file with this basic code:

    require "ost"

    Ost[:rss_feeds].each do |id|
      # ...
    end

It will pop items from the queue as soon as they become available. It
uses `BRPOPLPUSH` with a timeout that can be specified with the
`OST_TIMEOUT` environment variable.

Note that in these examples we are pushing numbers to the queue. As
we have unlimited queues, each queue should be specialized and the
workers must be smart enough to know what to do with the numbers they
pop.

Available methods
=================

`Ost[:example].push item`, `Ost[:some_queue] << item`: add `item` to
the `:example` queue.

`Ost[:example].pop { |item| ... }`, `Ost[:example].each { |item| ...
}`: consume `item` from the `:example` queue. If the block doesn't
complete successfully, the item will be left at a backup queue.

`Ost.stop`: halt processing for all queues.

`Ost[:example].stop`: halt processing for the `example` queue.

Failures
========

**Ost** stores in-process items in backup queues. That allows the
developer to deal with exceptions in a way that results adequate
for his application.

There is one backup queue for each worker, with the following
convention for naming the key in Redis: given a worker using the
`:events` queue, running in the hostname `domU-12-31-39-04-49-C7`
with the process id `28431`, the key for the backup queue will be
`ost:events:domU-12-31-39-04-49-C7:28431`.

Here's the explanation for each part:

* `ost`: namespace for all **Ost** related keys.
* `events`: name of the queue.
* `domU-12-31-39-04-49-C7`: hostname of the worker.
* `28431`: process id of the worker.

Priorities
----------

There's no concept of priorities, as each queue is specialized and you
can create as many as you want. For example, nothing prevents the
creation of the `:example_high_priority` or the
`:example_low_priority` queues.

Ost approach to queues and workers
----------------------------------------

Other projects and libraries provide queues and dumb workers that process jobs,
which are specialized for each task. The specialization takes place in the application side, 
and the job is serialized and pushed into a queue.

**Ost**, by contrast, just pushes numbers into specialized queues, and
uses workers that are subscribed to specific queues and know what to
do with the items they get. The total sum of logic is about the same,
but there's less communication and less data transfer with **Ost**.

Installation
------------

    Add this to your application's `shard.yml`:

    dependencies:
      ost-crystal:
        github: microspino/ost-crystal
        version: ~> '0.1.0'

Contributing
------------

1. Fork it ( https://github.com/microspino/ost-crystal/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

Contributors
------------

- [microspino](https://github.com/microspino) Microspino - creator, maintainer
