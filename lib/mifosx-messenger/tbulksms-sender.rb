require 'httpclient'
require_relative 'message-sender'

module MifosXMessenger
	class TBulkSMSSender < MessageSender
		@uri = nil
		@params = nil

		def initialize(options = {})
			@uri = options['uri'] || 'http://login.tbulksms.com/API/WebSMS/Http/v1.0a/index.php'
			@params = options
			@params['format'] ||= 'json'
			@params['sender'] ||= 'WEBSMS'
		end

		def send_sms(number, message)
			params = @params
			params['to'] = number
			params['message'] = message

			client = HTTPClient.new(:agent_name => 'MyAgent/0.1')
			client.post(uri, params)
		end
	end
end

