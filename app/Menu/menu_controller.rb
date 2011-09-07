require 'rho/rhocontroller'
require 'helpers/browser_helper'

class MenuController < Rho::RhoController
  include BrowserHelper

  #GET /Menu
  def index
    @menus = Menu.find(:all)
    render :back => '/app'
  end

  # GET /Menu/{1}
  def show
    @menu = Menu.find(@params['id'])
    if @menu
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Menu/new
  def new
    @menu = Menu.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Menu/{1}/edit
  def edit
    @menu = Menu.find(@params['id'])
    if @menu
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Menu/create
  def create
    @menu = Menu.create(@params['menu'])
    redirect :action => :index
  end

  # POST /Menu/{1}/update
  def update
    @menu = Menu.find(@params['id'])
    @menu.update_attributes(@params['menu']) if @menu
    redirect :action => :index
  end

  # POST /Menu/{1}/delete
  def delete
    @menu = Menu.find(@params['id'])
    @menu.destroy if @menu
    redirect :action => :index  end
end
