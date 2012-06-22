# By Oto Brglez - <oto.brglez@opalab.com>
$stdout.sync = true

require 'bundler/setup'
require 'amqp'
require './lib/bot_utils'
require 'logger'
require 'tweetstream' # https://github.com/intridea/tweetstream
require 'pp'

# Loading Bot Utils
BotUtils.init

TweetStream.configure do |config|
  config.consumer_key       = BotUtils.config["twitter_consumer_key"]
  config.consumer_secret    = BotUtils.config["twitter_consumer_secret"]
  config.oauth_token        = BotUtils.config["twitter_access_token"]
  config.oauth_token_secret = BotUtils.config["twitter_access_token_secret"]
  config.auth_method        = :oauth
end

# Logger
Log=Logger.new($stdout) if BotUtils.config["log_path"]==0
Log=Logger.new(BotUtils.config["log_path"]) if BotUtils.config["log_path"]!=0

Log.warn BotUtils.config.inspect


@targets = Hash.new

def get_targets
	targets = Hash.new
	BotUtils.collection('targets').each do |i|
		(i["target"]["twitter_handlers"].map! {|t| t=="" ? nil : t}).compact!
		if not(i["target"]["twitter_handlers"].nil?) and not(i["target"]["twitter_handlers"].empty?)
			targets[i["target"]["id"].to_s] = i["target"]["twitter_handlers"]
		end
	end
	@targets = targets
end

def find_targets(id)
	tgs = []
	@targets.each do |t|
		if t.last.include? id
			tgs << t.first
		end
	end
	tgs
end

@targets = get_targets

EM.run do
	client = TweetStream::Client.new

	# Errors...
	client.on_error do |error|
		Log.warn(error)
	end

	# My stream...
	client.userstream do |status|
		targets = find_targets(status.user.screen_name)
		Log.debug("Finding: #{status.user.screen_name}")
		
		unless targets.empty?
			Log.debug("Storing status from: #{status.user.screen_name}")
		
			pim = {
				bigkey: "twitter-#{status.id}",
				published_at: status.created_at,
				body: status.text,
				target_ids: targets,
				bots:["stream_twitter"],
				service: "twitter",
				type: "status",				
			}

			if not(status.geo.nil?)
				pim.merge!({
					location:  status.geo.coordinates
				})
			end

			status = BotUtils::PIM.new.put(pim)

			Log.warn("Failed response.") if status["status"] != "OK"
			Log.debug("Errors: "+(status["errors"].join(", "))) if status["status"] != "OK"
		end
  	end

  	# Update targets every minute
  	EM::PeriodicTimer.new(60) do
  		size = @targets.size
    	@targets = get_targets
    	size_new = @targets.size
    	Log.debug("Targets updated. Observing: #{@targets.size}") if size != size_new
    end

	Signal.trap("INT")  { EventMachine.stop }
	Signal.trap("TERM") { EventMachine.stop }
end