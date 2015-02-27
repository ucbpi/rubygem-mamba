require 'xmlrpc/client'

module Mamba
  class Client
    attr_reader :calls,:accounting

    def initialize(server,user=nil,password=nil,accounting=false)
      @client = XMLRPC::Client.new2("https://#{server}/rpc/api")

      if accounting
        @accounting = true
        @calls = Hash.new(0)
      end

      login(user,password) if ! (user.nil? or password.nil?)
    end

    def login(user,password)
      @key = @client.call('auth.login',user,password)
      _account('auth.login')

      # return true if we were successful
      true
    end

    def call(method,*params)
      _call(method,@key,*params)
    end

    def logout
      _call('auth.logout',@key)
    end

    private
    def _call(*params)
      _account(params[0])
      @client.call(*params)
    end

    def _account(call)
      @calls[call.to_sym]+=1 if @accounting

      # always return true
      return true
    end
  end
end
