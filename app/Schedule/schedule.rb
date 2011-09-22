require 'date'
require 'time'

# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Schedule
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with Schedule.
  # enable :sync

  #add model specifc code here
  
  def top
    start_time = parse_start_time
    ((start_time.hour * (40 + 2)) + (40 * (start_time.min / 60.0)) - 1).to_i
  end
  def height
    finish_time = parse_finish_time
    ((finish_time.hour * (40 + 2)) + (40 * (finish_time.min / 60.0)) - top - 6 - 3).to_i # ボーダーと影の高さを引く
  end
  def parse_start_date
    Time.parse(planned_start_date)
  end
  def parse_finish_date
    Time.parse(planned_finish_date)
  end
  def parse_start_time
    Time.parse(planned_start_time)
  end
  def parse_finish_time
    Time.parse(planned_finish_time)
  end
end
