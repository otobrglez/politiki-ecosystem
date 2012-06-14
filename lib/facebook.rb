# By Oto Brglez - <oto.brglez@opalab.com>

require 'httparty'

class Facebook
	include HTTParty
	format :json
	base_uri "https://graph.facebook.com"

	def object(id)
		self.class.get("/#{id}",query: {
			access_token: BotUtils.config["facebook_token"]
		}).parsed_response
	end
end