# By Oto Brglez - <oto.brglez@opalab.com>
$stdout.sync = true

require 'bundler/setup'
require 'twitter'
require 'amqp'
require './lib/bot_utils'
require 'logger'

# Loading Bot Utils
BotUtils.init

# Twitter Settings
Twitter.configure do |config|
  config.consumer_key = BotUtils.config["twitter_consumer_key"]
  config.consumer_secret = BotUtils.config["twitter_consumer_secret"]
  config.oauth_token = BotUtils.config["twitter_access_token"]
  config.oauth_token_secret = BotUtils.config["twitter_access_token_secret"]
end

# Logger
Log=Logger.new($stdout) if BotUtils.config["log_path"]==0
Log=Logger.new(BotUtils.config["log_path"]) if BotUtils.config["log_path"]!=0

EM.run do
	Log.debug("up.")

	connection = AMQP.connect(host: BotUtils.config["amqp_host"])
	channel  = AMQP::Channel.new(connection)

	queue = channel.queue("twitter.user", auto_delete: true)
	queue.subscribe do |target_id| 
		target = BotUtils.object(target_id)["target"]
		unless target.nil? 
			Log.info("doing: #{queue.name} for #{target['name']}")

			unless target["twitter_handlers"].nil? or target["twitter_handlers"].empty?
				target["twitter_handlers"].each do |handler|
					user = Twitter.user(handler)
					params= %w(followers_count friends_count listed_count favourites_count statuses_count)

					params.each do |param|
						status = BotUtils::Measurement.new(target).put(
							"twitter_#{param}",user["#{param}"],{
								handler:handler
							})

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

