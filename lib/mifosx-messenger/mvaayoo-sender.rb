require 'open-uri'
require 'net/http'
require_relative 'message-sender'

module MifosXMessenger
	class MVaayooSender < MessageSender
		@uri = nil
		@params = nil
		@client = nil

		def initialize(options = {})
			uri = options['uri'] || 'https://api.mVaayoo.com/mvaayooapi/MessageCompose'
			@params = options
			@uri = URI.parse(uri)
			@client = Net::HTTP.new(@uri.host, @uri.port)
			if @uri.scheme == 'https'
				@client.use_ssl = true
				@client.verify_mode = OpenSSL::SSL::VERIFY_NONE
			end
		end

		def send_sms(number, message)
			params = @params
			params['recipientno'] = number
			params['msgtxt'] = message

      querystr = params.map{|k,v|k+'='+v.to_s}.join('&')
			res = @client.request_get(@uri.request_uri + '?' + querystr)
			puts "SMS Request Sent. Response: " + res.body
		end
	end
end

