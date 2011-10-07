require "date"
require "lib/holiday"

module BrowserHelper

  def placeholder(label=nil)
    "placeholder='#{label}'" if platform == 'apple'
  end

  def platform
    System::get_property('platform').downcase
  end

  def selected(option_value,object_value)
    "selected=\"yes\"" if option_value == object_value
  end

  def checked(option_value,object_value)
    "checked=\"yes\"" if option_value == object_value
  end

  def calendar(year, month, schedules)
    tasks = schedules.inject(Array.new) do |tasks, schedule|
      day = schedule.parse_start_date.day
      tasks[day] = schedule.subject unless tasks[day]
      tasks
    end
    
    today = Date.today
    ret = "<table class='calendar_table'><tr class='header'><td class='sun'>日</td><td>月</td><td>火</td><td>水</td><td>木</td><td>金</td><td class='sat'>土</td>"
    (first = Date.new(year, month)).wday == 0 or ret << "</tr><tr>"
    ret << ("<td class='another'></td>" * first.wday)
    
    first.upto((first >> 1) - 1) do |day|
      day.wday != 0 or ret << "</tr><tr>"
      td_class = "day"
      if day.wday == 0 || day.national_holiday?
        td_class << " holiday"
      elsif day.wday == 6
        td_class << " sat"
      end
      
      td_class << " today" if day == today
      ret << "<td class='#{td_class}' day='#{day.day}'>"
      ret << "#{day.day}<br>&nbsp;"
      ret << "<img class='nomargin' src='/public/images/task.gif'>" if tasks[day.day]
      ret << "</td>"
    end
    
    ret << ("<td class='another'></td>" * (6 - ((first >> 1) - 1).wday))
    ret << "</tr></table>"
  end
  
  def week(year, month, day, schedules)
    tasks = schedules.inject(Array.new) do |tasks, schedule|
      if schedule
        start_day = schedule.parse_start_date.day
        tasks[start_day] = [] if tasks[start_day].nil?
        tasks[start_day] << schedule
      end
      tasks
    end
    
    day_of_week = ["日", "月", "火", "水", "木", "金", "土"]
    today = Date.today
    date = Date.new(year, month, day)
    first = date - date.wday
    
    ret = "<table class='calendar_table' cellpadding='0'>"
    0.upto(6) do |i|
      day = first + i
      
      ret << "<tr class='flick'>"
      0.upto(1) do |j|
        
        calendar_day = day + (j * 4)
        
        td_class = "day"
        if calendar_day.wday == 0 || calendar_day.national_holiday?
          td_class << " holiday"
        elsif calendar_day.wday == 6
          td_class << " sat"
        end
        td_class << " today" if calendar_day == today
        
        ret << "<td class='#{td_class}'><div class='day_cell' year='#{calendar_day.year}' month='#{calendar_day.month}' day='#{calendar_day.day}'>"
        ret << "#{calendar_day.year}/" unless calendar_day.year == date.year
        ret << "#{calendar_day.month}/" unless calendar_day.month == date.month
        ret << "#{calendar_day.day}(#{day_of_week[calendar_day.wday]})"
        if date.strftime("%Y%m") == calendar_day.strftime("%Y%m")
          if tasks[calendar_day.day]
            tasks[calendar_day.day].each do |schedule|
              start_time = schedule.parse_start_time.strftime("%H:%M")
              ret << "<div class='schedule'>#{start_time}-#{schedule.subject}</div>"
            end
          end
        end
        
        ret << "</div></td>"
      end
      ret << "</tr>"
    end
    
    ret << "</table>"
  end
end
