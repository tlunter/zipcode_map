require 'csv'
require 'chunky_png'

WIDTH = 1920

class ZipcodeImage
  def initialize(zipcodes, width, height)
    @zipcodes = zipcodes
    @image = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)
  end

  def draw
    @zipcodes.each do |zipcode|
      @image[zipcode.x, zipcode.y] = zipcode.color
    end
  end

  def save(path)
    @image.save(path, interlace: true)
  end
end

class FormattedZipcode
  attr_reader :zip, :lat, :long, :color, :x, :y

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
    @zip = row[0].to_i
    @long = Integer(row[3])
    @lat = Integer(row[4])
  end

  def scale(xy_scale, color_scale, height, min_zip)
    @color = ChunkyPNG::Color.from_hex(sprintf("%06x", ((zip - min_zip) * color_scale)))
    @x = (lat * xy_scale).round
    @y = height - (long * xy_scale).round
  end
end

zipcodes = FormattedZipcode.get_zipcodes("formatted_zipcodes.csv")
max_lat = zipcodes.map(&:lat).max
max_long = zipcodes.map(&:long).max
min_zip = zipcodes.map(&:zip).min
max_zip = zipcodes.map(&:zip).max

color_scale = "FFFFFF".to_i(16) / (max_zip - min_zip)

xy_scale = (WIDTH - 1).to_f / max_lat
height = (max_long.to_f / max_lat * WIDTH).round

zipcodes.each { |zipcode| zipcode.scale(xy_scale, color_scale, height, min_zip) }

ZipcodeImage.new(zipcodes, WIDTH, height + 1).tap(&:draw).save("zipcodes.png")
