# By Oto Brglez - <oto.brglez@opalab.com>

require 'bundler/setup'
require 'amqp'

EventMachine.run do
  connection = AMQP.connect(:host => 'mq.politiki.si')
  puts "Connecting to mq.politiki.si broker."

  channel  = AMQP::Channel.new(connection)
  queue    = channel.queue("politiki.twitter", :auto_delete => true)
#  exchange = channel.default_exchange

  queue.subscribe do |payload|
	puts "Received a message: #{payload}."
	puts payload.class

#    connection.close {
#      EventMachine.stop { exit }
#    }
  end

#  exchange.publish "Hello, world!", :routing_key => queue.name
end

