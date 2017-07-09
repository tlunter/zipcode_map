require 'csv'
require 'gosu'

WIDTH = 1920

class ZipcodeWindow < Gosu::Window
  def initialize(zipcodes, height)
    super(WIDTH, height)
    self.caption = "Zipcode Rainbow"

    @zipcodes = zipcodes
  end

  def draw
    @zipcodes.each do |zipcode|
      Gosu.draw_rect(zipcode.x, zipcode.y, 1, 1, zipcode.color)
    end
  end
end

class FormattedZipcode
  attr_reader :color, :lat, :long, :x, :y

  def self.get_zipcodes(path)
    zipcodes = []

    CSV.open(path, 'rb') do |csv|
      csv.each do |row|
        zipcodes << FormattedZipcode.new(row)
      end
    end

    zipcodes
  end

  def initialize(row)
    @color = Gosu::Color.new("FF0#{row[0]}".to_i(16))
    @long = Integer(row[3])
    @lat = Integer(row[4])
  end

  def scale(scale, height)
    @x = (lat * scale).round
    @y = height - (long * scale).round
  end
end

zipcodes = FormattedZipcode.get_zipcodes("formatted_zipcodes.csv")
max_lat = zipcodes.map(&:lat).max
max_long = zipcodes.map(&:long).max

scale = WIDTH.to_f / max_lat
height = (max_long.to_f / max_lat * WIDTH).round

zipcodes.each { |zipcode| zipcode.scale(scale, height) }

ZipcodeWindow.new(zipcodes, height).show
