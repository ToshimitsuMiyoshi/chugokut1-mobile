require 'rho/rhocontroller'

class BaseController < Rho::RhoController
  SERVER = 'http://192.168.191.150'
  
  @@current_user
  
  def current_user
    @@current_user
  end
  
  def current_user=(new_user)
    @@current_user = new_user
  end
  
  module AsyncHttp
    def self.get(args)
      args[:url] = "#{Rho::RhoConfig.server_url}#{args[:url]}" if args[:url]
      Rho::AsyncHttp.get(args)
    end
  end
end
