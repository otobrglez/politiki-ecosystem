# By Oto Brglez - <oto.brglez@opalab.com>
$stdout.sync = true

require 'bundler/setup'
require 'twitter'
require 'amqp'
require './lib/bot_utils.rb'
require './lib/facebook.rb'
require 'logger'

# Loading Bot Utils
BotUtils.init

# Logger
Log=Logger.new($stdout) if BotUtils.config["log_path"]==0
Log=Logger.new(BotUtils.config["log_path"]) if BotUtils.config["log_path"]!=0

EM.run do
	Log.debug("up.")

	connection = AMQP.connect(host: BotUtils.config["amqp_host"])
	channel  = AMQP::Channel.new(connection)

	queue = channel.queue("facebook.pages", auto_delete: true)
	queue.subscribe do |target_id| 
		target = BotUtils.object(target_id)["target"]
		unless target.nil? 
			Log.info("doing: #{queue.name} for #{target['name']}")

			params= %w(talking_about_count likes)
			
			unless target["facebook_page_uids"].nil? or target["facebook_page_uids"].empty? 
				target["facebook_page_uids"].each do |uid|
					page = Facebook.new.object(uid)

					params.each do |param|
						status = BotUtils::Measurement.new(target).put(
							"facebook_page_#{param}",page["#{param}"],{handler: uid})

						Log.warn("Failed response.") if status["status"] != "OK"
					end
				end
			end

			Log.debug("done.")
		end
	end

	Signal.trap("INT")  { EventMachine.stop }
	Signal.trap("TERM") { EventMachine.stop }
end

