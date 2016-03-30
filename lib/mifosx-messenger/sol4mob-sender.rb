require 'httpclient'
require 'json'

module MifosXMessenger
  class Sol4MobSender < MessageSender
    @uri = nil
    @params = nil
    @token = nil
    @rtoken = nil
    @valid_till = nil

    def _set_token(res)
      if 200 == res.status
        rbody = res.content
        robj = JSON.parse(rbody)
        payload = robj['payload']
        @token = payload['access_token']
        now = Time.new().to_i
        val_period = payload['validity_period']
        @valid_till = now + val_period
        @rtoken = payload['refresh_token']
      end
    end

    def _get_token
      uri = @uri + '/apis/auth'
      params = @params
      params['type'] = 'access_token'
      res = httpClient.post(uri, params.to_json)
      _set_token(res)
    end

    def initialize(options = {})
      @uri = options['uri'] || 'http://demo3275.sms-providers.com'
      @params = options
      httpClient = HTTPClient.new(:agent_name => 'MxMsngr/0.1')
      self._get_token
    end

    def _refresh_token
      uri = @uri + '/apis/auth'
      req = {
        'type' => 'refresh_token',
        'refresh_token' => @rtoken
      }
      res = httpClient.post(uri, req.to_json)
      _set_token(res)
    end

    def send_sms(number, message)
      if Time.new().to_i > @valid_till
        if @rtoken
          self._refresh_token
        else
          self._get_token
        end
      end
      uri = @uri + '/apis/sms/mt/v2/send'
      body = [ {
        'to' => [ number ],
        'from' => 'MxMsngr',
        'message' => message
      } ]
      res = $httpClient.post(uri, body.to_json, {
        'Content-Type' => 'application/json',
        'Authorization' => 'Bearer ' + $tk
      } )
      if 200 == res.status
        puts 'SMS request successful'
        rbody = res.content
        puts "Got " + rbody
        robj = JSON.parse(rbody)
        payload = robj['payload']
        if 'Array' == payload.class.to_s
          payload.each{ |p|
            puts "Operator Id: " + p['operator_id'] + "Cost:"+p['cost']
          }
        else
          puts "payload is a " + payload.class.to_s
        end
      else
        puts 'Fail. Got response ' + res.status.to_s + '::' + res.content
      end
    end
  end
end
