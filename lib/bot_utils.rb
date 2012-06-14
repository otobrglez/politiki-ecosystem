# By Oto Brglez - <oto.brglez@opalab.com>

require 'httparty'
require 'pathname'
require 'yaml'
require 'erb'

module BotUtils
	@@config = nil
	def self.config; @@config end

	class PolitikiObject
		include HTTParty
		format :json

		def get(id); self.class.get("/#{id}.json") end
		def collection(name); self.class.get("/#{name}.json") end
	end

	class Measurement < PolitikiObject
		attr_accessor :id
		def initialize(object); @id = object["id"] end

		def put(parameter,value,options={})

			measurement = ({
				parameter: parameter,
				value: value,
				target: id
			}).merge!(options)

			self.class.put("/measurement.json",body: {
				measurement: measurement }).parsed_response
		end
	end

	def self.init
		@@config = YAML.load(ERB.new(File.read("config.yml")).result)[ENV["POLITIKI_BOT_ENV"] || "developement"]
		
		PolitikiObject.send(:base_uri, @@config["politiki_uri"])
		PolitikiObject.send(:basic_auth,
			@@config["username"], @@config["password"])
	end

	def self.object(id)
		PolitikiObject.new.get(id).parsed_response
	end

	def self.collection name
		PolitikiObject.new.get(name).parsed_response
	end

end