#require 'rho/rhocontroller'
require 'base_controller'
require 'helpers/browser_helper'
#require 'json'

class LoginController < BaseController
  include BrowserHelper

  # GET /Login/new
  def new
    self.current_user = nil
    @login = Login.new
    render :action => :new, :back => url_for(:action => :new)
  end

  # POST /Login/do_login
  def do_login
    login = @params["login"]
    if login["username"].to_s != "" and login["password"].to_s != ""
      username = login["username"]
      password = login["password"]

      begin
        AsyncHttp.get(
          :url => "/login.json",
          :callback => url_for(:action => :httpget_callback),
          :body => "user[login]=#{username}&user[password]=#{password}"
        )
        render :action => :wait
      rescue Rho::RhoError => e
        @msg = e.message
        @login = Login.new
        render :action => :new
      end
    else
#      @msg = Rho::RhoError.err_message(Rho::RhoError::ERR_UNATHORIZED) unless @msg && @msg.length > 0
      @msg = "missing username or password"
      @login = Login.new
      render :action => :new
    end
  end

  # ANY /Login/do_logout
  def do_logout
    @msg = "ログアウトしました"
    self.current_user = nil
    @login = Login.new
    render :action => :new
  end

  def httpget_callback
    @@get_result = nil
    @@error_params = nil
    
    if @params["status"] != "ok"
      @@error_params = @params
      WebView.navigate( url_for(:action => :show_error) )
    else
      @@get_result = @params["body"]
      
      puts ""
      puts @@get_result
      puts User.new
      puts ""
      
      begin
        self.current_user = User.new
        self.current_user.update_attributes(@@get_result) if @@get_result

      rescue Exception => e
        current_user = User.new
        puts "Error : #{e}"
        @@get_result = "Error : #{e}"
      end
      
      WebView.navigate( url_for(:action => :show_result) )
    end
  end

  def show_result
    @msg = "show_result"
    if @@get_result
      render :action => :menu, :back => false
    else
      render :action => :new, :back => url_for(:action => :new)
    end
  end

  def show_error
    render :action => :error, :back => url_for(:action => :new)
  end
    
  def get_res
    @@get_result
  end

  def get_error
    @@error_params
  end

  def cancel_httpcall
    Rho::AsyncHttp.cancel( url_for(:action => :httpget_callback) )

    @@get_result  = 'Request was cancelled.'
    render :action => :webservicetest, :back => url_for(:action => :index)
  end

end
