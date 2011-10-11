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
    @document = Document.new
    @params['id'] =~ /\{(.+)\}/
    WebView.navigate("http://chugokut1.heroku.com/documents/#{$+}/download?auth_token=#{current_user.auth_token}")
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
