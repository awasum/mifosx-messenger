config_file 'config.yml'
require_relative 'lib/mifosx-messenger'

helpers do
	def request_header(h)
		env["HTTP_"+h.upcase.gsub('-','_')]
	end
end

get '/' do
	logger.info "Received GET on /"
		"Welcome to Mifos Messenger!"
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
			sndrSettings = settings.MessageSender
			sndrClass, sndrOpts = sndrSettings['class'], sndrSettings['options']
			messageSender = MifosXMessenger::const_get(sndrClass).new(sndrOpts)
			template = MifosXMessenger::MessageTemplates.new(settings.MessageSignature)
			rId = data["resourceId"]
			clientId = data["clientId"]
			client = mifosx.get_client(clientId, :fields => [ 'displayName', 'mobileNo' ] )
			number = client['mobileNo']
			message = nil
			path = entity+"."+action
			logger.info "Path: " + path
			case path
			when "LOAN.REPAYMENT"
				loanId = data["loanId"]
				loan = mifosx.get_loan(loanId, :fields => [ 'summary', 'currency', 'accountNo' ] )	# get outstanding
				trans = mifosx.get_loan_transaction(loanId, rId,
					:fields => [ 'type', 'currency', 'amount' ] ) # get amount
				message = template.loan_repayment(client, loan, trans)
			when "SAVINGSACCOUNT.DEPOSIT"
				savingsId = data["savingsId"]
				savings = mifosx.get_savings(savingsId)
				trans = mifosx.get_savings_transaction(savingsId, rId,
					:fields => [ 'amount', 'runningBalance' ] )
				message = template.savings_deposit(client, savings, trans)
			when "SAVINGSACCOUNT.WITHDRAWAL"
				savingsId = data["savingsId"]
				savings = mifosx.get_savings(savingsId)
				trans = mifosx.get_savings_transaction(savingsId, rId,
					:fields => [ 'amount', 'runningBalance' ] )
				message = template.savings_withdrawal(client, savings, trans)
			end
			if number and number.length >= 10
				logger.info "Number: " + number
        if message
          logger.info "Sending Message: " + message
          messageSender.send_sms(number, message)
        end
			end
		end
	end
end

