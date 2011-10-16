require 'helpers/browser_helper'

class MapUtil
  include BrowserHelper

  # View Map by address
  def viewMapByAddress(address, callback)
     puts "viewMapByAddress(address:#{address}, callback:#{callback}"

     url = "http://maps.google.com/maps/api/geocode/json?" +
       "address=#{address}&" +
       "sensor=true"
     #puts url

     res = Rho::AsyncHttp.get(
       :url => url,
       #:headers => {"Cookie" => cookie},
     )
     #puts res.inspect

     if res["status"] == "ok" # && res["body"]["status"] == "OK"
       #puts res["body"].inspect
       #puts res["body"]["results"][0]["geometry"]["location"]["lat"]
       #puts res["body"]["results"][0]["geometry"]["location"]["lng"]

       to_lat = res["body"]["results"][0]["geometry"]["location"]["lat"]
       to_lng = res["body"]["results"][0]["geometry"]["location"]["lng"]
     else
       to_lat =  '34.4893270'
       to_lng = '133.3614320'
     end

     viewMap address, to_lat, to_lng, callback
  end

  # View Map by location
  def viewMap(address, to_lat, to_lng, callback)
     puts "viewMap(address:#{address}, to_lat:#{to_lat}, to_lng:#{to_lng}, callback:#{callback}"

     if GeoLocation.known_position?
        from_lat = GeoLocation.latitude
        from_lng = GeoLocation.longitude
     else
       from_lat =  34.3932857
       from_lng = 132.4705439
       from_lat =  34.4893270
       from_lng = 133.3614320
       from_lat =  35.005018
       from_lng = 135.889155
     end

     if callback
        #GeoLocation.set_notification(url_for(:action => :geo_callback), "")
        GeoLocation.set_notification(callback, "")
     end

     puts "from:#{from_lat},#{from_lng} => to:#{to_lat},#{to_lng}"
     puts "distance: #{GeoLocation.haversine_distance(from_lat,from_lng,to_lat,to_lng)}"

     #region = [@params['latitude'], @params['longitude'], 1/69.0, 1/69.0] #miles
     #region = [@params['latitude'], @params['longitude'], 1/111.0, 1/111.0] #km
     region = [(to_lat + from_lat) / 2, (to_lng + from_lng) / 2,
               (to_lat - from_lat).abs, (to_lng - from_lng).abs]

     url = "http://maps.google.jp/maps/api/directions/json?" +
        "origin=#{from_lat},#{from_lng}&" +
        "destination=#{to_lat},#{to_lng}&" +
        "mode=walking&" +
        "language=ja&" +
        "sensor=true"
     #puts url

     res2 = Rho::AsyncHttp.get(
        :url => url,
        #:headers => {"Cookie" => cookie},
     )
     #puts res2.inspect
     #puts res2["status"]

#      if res2["status"] == "ok"
#      end

     myannotations = []

     #puts res2["body"].inspect
     #puts res2["body"]["status"]
     #puts res2["body"]["routes"].size
     #puts res2["body"]["routes"][0]["legs"].size
     #puts res2["body"]["routes"][0]["legs"][0]["steps"].size

     res2["body"]["routes"][0]["legs"][0]["steps"].each do |step|
        #puts step.inspect

        title = step["html_instructions"]
        title = title.gsub(/\<\/?[bB]\>/,  "")
        #puts title

        myannotations << {
          :latitude =>  step["start_location"]["lat"],
          :longitude => step["start_location"]["lng"],
          :title => title,
          :subtitle => step["distance"]["text"],
          #:url => "/app/GeoLocation/show?city=Original Location",
          #:image => '/public/images/marker_blue.png', :image_x_offset => 8, :image_y_offset => 32
        }
     end

     myannotations << {
        :latitude =>  to_lat,
        :longitude => to_lng,
        :title => address,
        #:subtitle => @params['map']['address'],
        #:url => "/app/GeoLocation/show?city=Original Location"
     }

     map_params = {
        #:provider => "Google",
        :provider => "ESRI",
        :settings => {
           #:map_type => "roadmap",
           :map_type => "standard",
           :region => region,
           :zoom_enabled => true, :scroll_enabled => true, :shows_user_location => true,
           #:api_key => '0jDNua8T4Teq0RHDk6_C708_Iiv45ys9ZL6bEhw'
        },
        :annotations => myannotations
     }

     #puts map_params.inspect
     puts "-------------------------"
     MapView.create map_params
  end

  # GeoLocation
  def geo_callback(params)
    puts "geo_callback(#{params.inspect})"

    # navigate to `show_location` page if GPS receiver acquire position  
    if params['known_position'].to_i != 0 && params['status'] =='ok'    
      puts "known_position:#{params['known_position']}, status:#{params['status']}"
      #WebView.navigate url_for(:action => :show_location) 
      viewMap params['latitude'], params['longitude']
    end   
    # show error if timeout expired and GPS receiver didn't acquire position
    if params['available'].to_i == 0 || params['status'] !='ok'
      puts "available:#{params['available']}, status:#{params['status']}"
      #WebView.navigate url_for(:action => :show_location_error) 
    end
    # do nothing, still wait for location 
  end

end
