require 'sinatra'
require 'sinatra/config_file'
require 'json'

config_file 'config.yml'
require_relative 'lib/mifosx-messenger'

helpers do
	def request_header(h)
		env["HTTP_"+h.upcase.gsub('-','_')]
	end
end

get '/' do
	logger.info "Received GET on /"
	"Welcome to Mifos-messenger!"
end

post '/' do
	apiKey = request_header("X-Mifos-API-Key")
	entity = request_header("X-Mifos-Entity")
	action = request_header("X-Mifos-Action")

	if request.body.size > 0
		data = JSON.parse(request.body.string)
	end

	if entity
		if action
			mifosx = MifosXMessenger::MifosXHelper.new(settings.MifosOptions)
			messageSender = MifosXMessenger::TBulkSMSSender.new(settings.MessageSender['options'])
			template = MifosXMessenger::MessageTemplates.new
			rId = data["resourceId"]
			clientId = data["clientId"]
			client = mifosx.get_client(clientId, :fields => [ 'displayName', 'mobileNo' ] )
			number = client['mobileNo']
			message = nil
			case entity+"."+action
			when "loan.repayment"
				loanId = data["loanId"]
				loan = mifosx.get_loan(loanId, :fields => [ 'summary' ] )	# get outstanding
				trans = mifosx.get_loan_transaction(loanId, rId,
					:fields => [ 'type', 'currency', 'amount' ] ) # get amount
				message = template.loan_repayment(client, loan, trans)
			when "savings.deposit"
				savingsId = data["savingsId"]
				trans = mifosx.get_savings_transaction(savingsId, rId,
					:fields => [ 'transactionType', 'currency', 'amount', 'runningBalance' ] ) # get amount & balance
				message = template.savings_deposit(client, trans)
			end
			logger.info "Number: " + number + ", Message: " + message
			if message and number and number.length >= 10
				logger.info "Sending SMS.."
				messageSender.send_sms(number, message)
			end
		end
	end
end

