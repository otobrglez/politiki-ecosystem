# By Oto Brglez - <oto.brglez@opalab.com>

$stdout.sync = true

require 'bundler/setup'
require './lib/bot_utils.rb'
require 'clockwork'
require 'pp'
require 'amqp'

include Clockwork
BotUtils.init


# Opens connection and triggers measurements for targets
def dispatch_measurement_for_objects measurements=["facebook.pages","twitter.user","peerindex","klout"]
	targets = BotUtils.collection('targets').map!{|i| i["target"]["id"] }

	AMQP.start(BotUtils.config["amqp_url"]) do |connection|
		AMQP::Channel.new do |channel|
			log "Opening channel: ##{channel.id}"
			
			measurements.each do |measurement|
				queue    = channel.queue(measurement, :auto_delete => true)
				targets.each do |target|
					exchange = channel.default_exchange
	 				exchange.publish target, :routing_key => queue.name
		 		end
			end

			channel.close {
				log "Closing ##{channel.id}"
				return true
			}
		end
	end

end


handler do |job|
	if job == "measurement.hf"
		dispatch_measurement_for_objects
	end
end

every(30.minutes,'measurement.hf') 