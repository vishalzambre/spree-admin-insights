class Spree::Report::TimedObservation < Spree::Report::Observation

  extend Forwardable

  attr_accessor :date, :hour, :reportable_keys

  def_delegators :date, :day, :month, :year

  def initialize
    super
    self.hour = 0
  end

  def describes?(result, time_scale)
    case time_scale
    when :hourly
      result['hour'].to_s == hour.to_s && result['day'].to_s == day.to_s
    when :daily
      result['day'].to_s == day.to_s && result['month'].to_s == month.to_s
    when :monthly
      result['month'].to_s == month.to_s && result['year'].to_s == year.to_s
    when :yearly
      result['year'].to_s == year.to_s
    end
  end

  def month_name
    "#{Date::MONTHNAMES[month]} #{year}"
  end

  def hour_name
    if hour == 23
      return "23:00 - 00:00"
    else
      return "#{ hour }:00 - #{ hour + 1 }:00"
    end
  end

  def day_name
    "#{ day } #{ month_name }"
  end

  def to_h
    super.merge({day_name: day_name, month_name: month_name, year: year, hour_name: hour_name})
  end

end
