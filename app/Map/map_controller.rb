require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'map/map_util'

class MapController < Rho::RhoController
  include BrowserHelper

  # GET /Map
  def index
    @map = Map.new
    #@map.latitude  =  '34.3982050'
    #@map.longitude = '132.4758240'
    @map.address   = '広島駅'
    render :back => '/app'
  end


  # Post /Map/view
  def view
     puts "-------------------------"
     puts @params.inspect
     #puts @params['map']

     if @params['map']['address'].length > 0
       address = @params['map']['address']
       puts "address:#{address}"

       util = MapUtil.new
       util.viewMapByAddress address, url_for(:action => :geo_callback)
     else
       to_lat   = @params['map']['latitude'].to_f
       to_lng   = @params['map']['longitude'].to_f
       puts "to:#{to_lat},#{to_lng}"

       util = MapUtil.new
       util.viewMap to_lat, to_lng, url_for(:action => :geo_callback)
     end

     redirect :action => :index
  end

  # GeoLocation
  def geo_callback
     puts "-------------------------"
     puts @params.inspect

     util = MapUtil.new
     util.geo_callback @params
  end

end
