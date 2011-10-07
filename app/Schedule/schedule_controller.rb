#require 'rho/rhocontroller'
require 'base_controller'
require 'helpers/browser_helper'
require 'Map/map_util'
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
    @@next_action = :show_schedule
    @params['id'] =~ /\{(.+)\}/
    AsyncHttp.get(
      :url      => "/schedules/#{$+}.json?auth_token=#{current_user.auth_token}",
      :callback => url_for(:action => :httpget_callback)
    )
    render :action => :wait
  end

  def show_schedule
    @schedule = Schedule.new(@@get_result)
    if @schedule
      @customer = Customer.new(@schedule.customer)
      @date = @schedule.parse_start_date
      @back = {:year => @date.year, :month => @date.month, :day => @date.day}
      render :action => :show
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

  def day_schedules
    if current_user
      begin
        time = Time.new
        @@year  = @params["year"] || time.year
        @@month = @params["month"] || time.month
        @@day   = @params["day"] || time.day
        
        #puts ""
        #puts "POST Parameters : auth_token=#{current_user.auth_token}&year=#{@@year}&month=#{@@month}&day=#{@@day}"
        #puts ""
        
        @@next_action = :show_day
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
  
  def month_schedules
    if current_user
      begin
        time = Time.new
        @@year  = @params["year"] || time.year
        @@month = @params["month"] || time.month
        
        #puts ""
        #puts "POST Parameters : auth_token=#{current_user.auth_token}&year=#{@@year}&month=#{@@month}"
        #puts ""
        
        @@next_action = :show_month
        AsyncHttp.get(
          :url      => "/schedules.json?auth_token=#{current_user.auth_token}&year=#{@@year}&month=#{@@month}",
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
  
  def week_schedules
    if current_user
      begin
        time = Time.new
        @@year  = @params["year"] || time.year
        @@month = @params["month"] || time.month
        @@day = @params["day"] || time.day
        
        #puts ""
        #puts "POST Parameters : auth_token=#{current_user.auth_token}&year=#{@@year}&month=#{@@month}"
        #puts ""
        
        @@next_action = :show_week
        AsyncHttp.get(
          :url      => "/schedules.json?auth_token=#{current_user.auth_token}&year=#{@@year}&month=#{@@month}",
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

  # GET /Schedule/httpget_callback
  def httpget_callback
    @@get_result = nil
    @@error_params = nil
    
    if @params["status"] != "ok"
      @@error_params = @params
      WebView.navigate( url_for(:action => :show_error) )
    else
      @@get_result = @params["body"]
      WebView.navigate( url_for(:action => @@next_action) )
    end
  end
  
  def show_day
    if @@get_result
      @schedules = []
      unless @@get_result == "null"
        @@get_result.each do |res|
          @schedules << Schedule.new(res)
        end
      end
      
      @current_hour = Time.new.hour
      @day = Date::new(@@year.to_i, @@month.to_i, @@day.to_i)
      @today = {:year => @day.year, :month => @day.month, :day => @day.day}
      @yesterday = {:year => (@day - 1).year, :month => (@day - 1).month, :day => (@day - 1).day}
      @tommorow = {:year => (@day + 1).year, :month => (@day + 1).month, :day => (@day + 1).day}
      
      render :action => :day_schedules
    else
      render :action => :new
    end
  end

  def show_month
    if @@get_result
      @schedules = []
      unless @@get_result == "null"
        @@get_result.each do |res|
          @schedules << Schedule.new(res)
        end
      end
      
      @month = Date::new(@@year.to_i, @@month.to_i, 1)
      @this_month = {:year => @month.year,        :month => @month.month}
      @prev_month = {:year => (@month << 1).year, :month => (@month << 1).month}
      @next_month = {:year => (@month >> 1).year, :month => (@month >> 1).month}
      
      render :action => :month_schedules
    else
      render :action => :new
    end
  end

  def show_week
    if @@get_result
      @schedules = []
      unless @@get_result == "null"
        @@get_result.each do |res|
          @schedules << Schedule.new(res)
        end
      end
      
      @day = Date::new(@@year.to_i, @@month.to_i, @@day.to_i)
      @prev_week = {:year => (@day - 6).year, :month => (@day - 6).month, :day => (@day - 6).day}
      @next_week = {:year => (@day + 6).year, :month => (@day + 6).month, :day => (@day + 6).day}
      
      render :action => :week_schedules
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

  # Post /Schedule/map
  def map
     puts "-------------------------"
     puts @params.inspect
     address  = @params['map']['address']
     to_lat   = @params['map']['latitude'].to_f
     to_lng   = @params['map']['longitude'].to_f
     puts "to:#{address},#{to_lat},#{to_lng}"

     util = MapUtil.new
     util.viewMap address, to_lat, to_lng, url_for(:action => :geo_callback)

     render :action => :show
  end

  # GeoLocation
  def geo_callback
     puts "-------------------------"
     puts @params.inspect

     util = MapUtil.new
     util.geo_callback @params
  end
end
