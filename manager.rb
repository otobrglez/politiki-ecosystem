# By Oto Brglez - <oto.brglez@opalab.com>

require 'bundler/setup'
require 'amqp'

if ARGV[0].nil?
	puts "Missing channel."
	exit(1)
end

if ARGV[1].nil?
	puts "Missing value."
	exit(1)
end

EM.run do
	puts "manager: up."
	puts "manager: queue: #{ARGV[0]}"
	puts "manager: value: #{ARGV[1]}"

	connection = AMQP.connect(:host => 'mq.politiki.si')
	channel  = AMQP::Channel.new(connection)
	queue    = channel.queue(ARGV[0], :auto_delete => true)

	exchange = channel.default_exchange
	
	exchange.publish ARGV[1], :routing_key => queue.name do 
		
		EM.stop
	end

	Signal.trap("INT")  { EventMachine.stop }
	Signal.trap("TERM") { EventMachine.stop }
end