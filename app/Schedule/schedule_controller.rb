#require 'rho/rhocontroller'
require 'base_controller'
require 'helpers/browser_helper'
require 'date'
require 'time'

class ScheduleController < BaseController
  include BrowserHelper

  #GET /Schedule
  def index
    @schedules = Schedule.find(:all)
    render :back => url_for(:controller => :login, :action => :menu)
  end

  # GET /Schedule/{1}
  def show
    @schedule = Schedule.find(@params['id'])
    if @schedule
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Schedule/new
  def new
    @schedule = Schedule.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Schedule/{1}/edit
  def edit
    @schedule = Schedule.find(@params['id'])
    if @schedule
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Schedule/create
  def create
    @schedule = Schedule.create(@params['schedule'])
    redirect :action => :index
  end

  # POST /Schedule/{1}/update
  def update
    @schedule = Schedule.find(@params['id'])
    @schedule.update_attributes(@params['schedule']) if @schedule
    redirect :action => :index
  end

  # POST /Schedule/{1}/delete
  def delete
    @schedule = Schedule.find(@params['id'])
    @schedule.destroy if @schedule
    redirect :action => :index
  end

  # GET /Schedule/httpget_callback
  def httpget_callback
    @@get_result = nil
    @@error_params = nil
    
    if @params["status"] != "ok"
      @@error_params = @params
      WebView.navigate( url_for(:action => :show_error) )
    else
      @@get_result = @params["body"]
      WebView.navigate( url_for(:action => :show_result) )
    end
  end
  
  def day_schedules
    if current_user
      begin
        time = Time.new
        @@year  = @params["year"] || time.year
        @@month = @params["month"] || time.month
        @@day   = @params["day"] || time.day
        
        puts ""
        puts "POST Parameters : auth_token=#{current_user.auth_token}&year=#{@@year}&month=#{@@month}&day=#{@@day}"
        puts ""
        
        AsyncHttp.get(
          :url      => "/schedules.json?auth_token=#{current_user.auth_token}&year=#{@@year}&month=#{@@month}&day=#{@@day}",
          :callback => url_for(:action => :httpget_callback)
        )
        
        render :action => :wait
      rescue Rho::RhoError => e
        @msg = e.message
        @login = Login.new
        render :action => :new
      end
    else
      WebView.navigate( url_for(:controller => :Login, :action => :new) )
    end
  end
  
  def show_result
    if @@get_result
      @schedules = []
      @@get_result.each do |res|
        @schedules << Schedule.new(res)
      end
      
      @day = Date::new(@@year.to_i, @@month.to_i, @@day.to_i)
      @yesterday = {:year => (@day - 1).year, :month => (@day - 1).month, :day => (@day - 1).day}
      @tommorow = {:year => (@day + 1).year, :month => (@day + 1).month, :day => (@day + 1).day}
      
      render :action => :day_schedules
    else
      render :action => :new
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
