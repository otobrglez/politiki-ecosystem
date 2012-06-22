# By Oto Brglez - <oto.brglez@opalab.com>
$stdout.sync = true

require 'bundler/setup'
require 'twitter'
require 'amqp'
require './lib/bot_utils.rb'
require 'klout'
require 'logger'

# Loading Bot Utils
BotUtils.init

# Logger
Log=Logger.new($stdout) if BotUtils.config["log_path"]==0
Log=Logger.new(BotUtils.config["log_path"]) if BotUtils.config["log_path"]!=0


Klout.api_key = BotUtils.config["klout_key"]

EM.run do
	Log.debug("up.")

	connection = AMQP.connect(BotUtils.config["amqp_url"])
	channel  = AMQP::Channel.new(connection)

	queue = channel.queue("klout", auto_delete: true)
	queue.subscribe do |target_id| 
		target = BotUtils.object(target_id)["target"]
		unless target.nil? 
			Log.info("doing: #{queue.name} for #{target['name']}")

			unless target["twitter_handlers"].nil? or target["twitter_handlers"].empty?
				target["twitter_handlers"].each do |handler|
					if not(handler.nil?) and handler.strip != ""
						begin
							klout_id = Klout::Identity.find_by_screen_name(handler)
							user = Klout::User.new(klout_id.id)

							#if not(index.nil?) and not(index.empty?)
								
							status = BotUtils::Measurement.new(target).put(
								"klout_score",user.score.score,{
									handler:handler
								})

							if status["status"] == "OK"
								Log.debug("Sleeping for 10 sec.")
								sleep(10)
							else
								Log.warn("Failed response.") 
							end
							
							#end
						rescue Exception => e  
							Log.warn("Parser error: #{e.message}")
						end
					end
				end
			end

			Log.debug("done.")
		end
	end

	Signal.trap("INT")  { EventMachine.stop }
	Signal.trap("TERM") { EventMachine.stop }
end

