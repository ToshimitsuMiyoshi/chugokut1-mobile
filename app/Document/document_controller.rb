#require 'rho/rhocontroller'
require 'base_controller'
require 'helpers/browser_helper'

class DocumentController < BaseController #Rho::RhoController
  include BrowserHelper

  #GET /Document
  def index
    @documents = Document.find(:all)
    render :back => '/app'
  end

  # GET /Document/{1}
  def show
#    @document = Document.find(@params['id'])
#    if @document
#      render :action => :show, :back => url_for(:action => :index)
#    else
#      redirect :action => :index
#    end
#    @document = Document.new
#    @params['id'] =~ /\{(.+)\}/
#    WebView.navigate("http://chugokut1.heroku.com/documents/#{$+}/download?auth_token=#{current_user.auth_token}")

    #puts "--------------------------------"
    #puts @params.inspect
    @params['id'] =~ /\{(.+)\}/
    id = $+
    url = "http://chugokut1.heroku.com/documents/#{id}/download?auth_token=#{current_user.auth_token}"
    #puts url

    #base_name = File.basename(url)
    base_name = "document#{id}.pdf"
    @@file_name = File.join(Rho::RhoApplication::get_base_app_path(), base_name)

    File.delete @@file_name if File.exist?(@@file_name)

    Rho::AsyncHttp.download_file(
      :url => url,
      :filename => @@file_name,
      :headers => {},
      :callback => (url_for :action => :httpdownload_callback),
      :callback_param => "" )
      
    render :action => :wait
  end
  
  def httpdownload_callback
    #puts "httpdownload_callback: #{@params}"
    if @params['status'] != 'ok'
        @@error_params = @params
        WebView.navigate ( url_for :action => :show_error )        
    else
        WebView.navigate ( url_for :action => :show_result )
    end
  end

  def show_result
    System.open_url(@@file_name)
    redirect :controller => :Schedule, :action => :show_schedule
  end

  def show_error
    render :action => :error, :back => '/app/Schedule/show_schedule'
  end
    
  def cancel_httpcall
    #puts "cancel_httpcall"
    Rho::AsyncHttp.cancel()  # url_for( :action => :httpdownload_callback) )
    @@get_result  = 'Request was cancelled.'
    redirect :controller => :Schedule, :action => :show_schedule
  end

  # GET /Document/new
  def new
    @document = Document.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Document/{1}/edit
  def edit
    @document = Document.find(@params['id'])
    if @document
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Document/create
  def create
    @document = Document.create(@params['document'])
    redirect :action => :index
  end

  # POST /Document/{1}/update
  def update
    @document = Document.find(@params['id'])
    @document.update_attributes(@params['document']) if @document
    redirect :action => :index
  end

  # POST /Document/{1}/delete
  def delete
    @document = Document.find(@params['id'])
    @document.destroy if @document
    redirect :action => :index  end
end
