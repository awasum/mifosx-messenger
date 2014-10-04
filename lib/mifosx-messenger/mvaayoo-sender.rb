require 'httpclient'
require_relative 'message-sender'

module MifosXMessenger
	class MVaayooSender < MessageSender
		@uri = nil
		@params = nil
		@client = nil

		def initialize(options = {})
			@uri = options['uri'] || 'https://api.mVaayoo.com/mvaayooapi/MessageCompose'
			@params = options
			@client = HTTPClient.new(:agent_name => 'MyAgent/0.1')
			@client.ssl_config.set_trust_ca('/tmp/Go_Daddy_Root_Certificate_Authority_-_G2.crt')
		end

		def send_sms(number, message)
			params = @params
			params['recipientno'] = number
			params['msgtxt'] = message

			@client.get(@uri, params)
		end
	end
end

