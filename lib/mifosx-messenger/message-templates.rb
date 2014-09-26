module MifosXMessenger
	class MessageTemplates
		@signature = nil
		def initialize
			@signature = 'Regards, SMSSS'
		end

		def loan_repayment(client, loan, trans)
			"Dear #{client['displayName']}, your loan account ##{loan['id']} recorded a repayment of " +
				"#{trans['currency']['code']} #{trans['amount']}. Current outstanding: " +
				"#{loan['currency']['code']} #{loan['summary']['totalOutstanding']}\n- #{@signature}"
		end

		def savings_deposit(client, trans)
			"Dear #{client['displayName']}, your savings account #{trans['accountNo']} recorded a deposit of " +
				"#{trans['currency']['code']} #{trans['amount']}. Current balance: " +
				"#{trans['currency']['code']} #{trans['runningBalance']}.\n- #{@signature}"
		end

		def savings_withdrawal(client, trans)
			"Dear #{client['displayName']}, your savings account #{trans['accountNo']} recorded a withdrawal of " +
				"#{trans['currency']['code']} #{trans['amount']}. Current balance: " +
				"#{trans['currency']['code']} #{trans['runningBalance']}.\n- #{@signature}"
		end
	end
end
