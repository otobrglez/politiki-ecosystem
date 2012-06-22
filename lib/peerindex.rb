# By Oto Brglez - <oto.brglez@opalab.com>
require 'httparty'

class PeerIndex
	include HTTParty
	format :json

	base_uri "http://api.peerindex.net/v2"

	def get(handler)
		self.class.get("/profile/show.json",query: {
			id:handler,
			api_key: BotUtils.config["peerindex_key"]
		}).parsed_response
	end
end