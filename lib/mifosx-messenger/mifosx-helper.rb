require 'base64'
require 'httpclient'
require 'json'

module MifosXMessenger
	class MifosXHelper

		@baseUrl = nil
		@http = nil
		@headers = nil

		def initialize(options = {})
			@baseUrl = options['baseUrl'] || 'https://demo.openmf.org/mifosng-provider/api/v1'
			tenantId = options['tenantId'] || 'default'
			user = options['user'] || 'mifos'
			pass = options['pass'] || 'password'
			@http = HTTPClient.new(:agent_name => 'MifosMessenger/0.1')		
			@headers = {
				'X-Mifos-Platform-TenantId' => tenantId,
				'Authorization' => 'Basic '+Base64.encode64(user+':'+pass).gsub("\n",'')
			}
		end

		def get_entity_uri(entity, entityId, prefUrl = @baseUrl)
			[prefUrl, entity, entityId.to_s].join('/')
		end

		def get_entity(uri, entityId, options = {})
			params = nil
			if fields = options[:fields]
				params = { 'fields' => fields.join(',') }
			end
			if (res = @http.get(uri, params, @headers))
				return JSON.parse(res.content)
			end
		end

		def get_client(clientId, options = {})
			uri = get_entity_uri('clients', clientId)
			get_entity(uri, options)
		end

		def get_loan(loanId, options = {})
			uri = get_entity_uri('loans', loanId)
			get_entity(uri, options)
		end

		def get_loan_transaction(loanId, transId, options = {})
			loan_uri = get_entity_uri('loans', loanId)
			uri = get_entity_uri('transactions', transId, loan_uri)
			get_entity(uri, options)
		end

		def get_savings(savingsId, options = {})
			uri = get_entity_uri('savingsaccounts', savingsId)
			get_entity(uri, options)
		end

		def get_savings_transaction(savingsId, transId, options = {})
			savings_uri = get_entity_uri('savingsaccounts', savingsId)
			uri = get_entity_uri('transactions', transId, savings_uri)
			get_entity(uri, options)
		end
	end
end
