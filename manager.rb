# By Oto Brglez - <oto.brglez@opalab.com>

require 'bundler/setup'
require 'amqp'

EventMachine.run do
  
  puts "Manager for mq.politiki.si"

  connection = AMQP.connect(:host => 'mq.politiki.si')
  channel  = AMQP::Channel.new(connection)
  exchange = channel.default_exchange
  
  queue    = channel.queue("politiki.twitter", :auto_delete => true)

  exchange.publish ({ime: "Janez", id:123}), :routing_key => queue.name


  #connection.close {
  #    EventMachine.stop { exit }
  #}
end