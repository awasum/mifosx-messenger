require 'httpclient'

module AbstractInterface

  class InterfaceNotImplementedError < NoMethodError
  end

  def self.included(klass)
    klass.send(:include, AbstractInterface::Methods)
    klass.send(:extend, AbstractInterface::Methods)
  end

  module Methods

    def api_not_implemented(klass)
      caller.first.match(/in \`(.+)\'/)
      method_name = $1
      raise AbstractInterface::InterfaceNotImplementedError.new("#{klass.class.name} needs to implement '#{method_name}' for interface #{self.name}!")
    end

  end

end

module MifosXMessenger
	class MessageSender
		include AbstractInterface

		def send_sms(number, message)
			MessageSender.api_not_implemented(self)
		end
	end
end

