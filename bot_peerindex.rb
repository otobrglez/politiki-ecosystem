# By Oto Brglez - <oto.brglez@opalab.com>
$stdout.sync = true

require 'bundler/setup'
require 'twitter'
require 'amqp'
require './lib/bot_utils.rb'
require './lib/peerindex.rb'
require 'logger'

# Loading Bot Utils
BotUtils.init

# Logger
Log=Logger.new($stdout) if BotUtils.config["log_path"]==0
Log=Logger.new(BotUtils.config["log_path"]) if BotUtils.config["log_path"]!=0

EM.run do
	Log.debug("up.")

	connection = AMQP.connect(BotUtils.config["amqp_url"])
	channel  = AMQP::Channel.new(connection)

	queue = channel.queue("peerindex", auto_delete: true)
	queue.subscribe do |target_id| 
		begin
			target = BotUtils.object(target_id)["target"]
			unless target.nil? 
				Log.info("doing: #{queue.name} for #{target['name']}")

				params= %w(activity audience authority peerindex)
				unless target["twitter_handlers"].nil? or target["twitter_handlers"].empty?
					target["twitter_handlers"].each do |handler|
						if not(handler.nil?) and handler.strip != ""

							index = PeerIndex.new.get(handler)
							
							if not(index.nil?) and not(index.empty?)
								params.each do |param|
									status = BotUtils::Measurement.new(target).put(
										"peerindex_#{param}",index["#{param}"],{
											handler:handler
										})

									Log.warn("Failed response.") if status["status"] != "OK"
								end
							end

						end
					end
				end

				Log.debug("done.")
			end
		rescue Exception => e  
			Log.warn("Parser error: #{e.message}")
		end
	end

	Signal.trap("INT")  { EventMachine.stop }
	Signal.trap("TERM") { EventMachine.stop }
end

