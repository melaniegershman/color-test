require 'benchmark'

class WelcomeController < ApplicationController
  NUMBER_OF_IMAGES = 15
  def index
    collect_frequencies_of_images(NUMBER_OF_IMAGES)
    # the below is for testing in terminal only
    @hex_codes.each_with_index { |hex, index| p "The top 5 colors for image #{index} are: #{hex}"  }
  end

  private

  def collect_frequencies_of_images(number_of_images)
    @hex_codes = []
    number_of_images.times do |number|
      number_of_colors = 256
      path = "app/assets/images/#{number}.jpg"
      image = load_image(path, number_of_colors)
      total_depth = image.columns * image.rows
      colors = get_hex(path, number_of_colors, total_depth)
      colors = colors.sort_by {|color| color[:percent]}
      colors.each {|hex_code| @hex_codes << hex_code[:hex]}
      # binding.pry
    end
    @hex_codes = @hex_codes.shift(5)
    # binding.pry
  end
# new
  def load_image(path, number_of_colors)
    image = Magick::Image.read(path).first
    image.quantize(number_of_colors, Magick::RGBColorspace)
  end

  def sort_color_histogram(path, number_of_colors)
    quantized_image = load_image(path, number_of_colors)
    sorted_histogram = quantized_image.color_histogram.sort {|color, frequency| frequency[1] <=> color[1]}
  end

  def get_hex(path, number_of_colors, total_depth)
    @hex_codes = []
    sorted_histogram = sort_color_histogram(path, number_of_colors)
    # byebug

    sorted_histogram.count.times do |i|
      h = sorted_histogram[i]

      r1 = h[0].red/256
      g1 = h[0].green / 256
      b1 = h[0].blue / 256

      r2 = r1.to_s(16)
      g2 = g1.to_s(16)
      b2 = b1.to_s(16)

      r2 += r2 unless r2.length == 2
      g2 += g2 unless g2.length == 2
      b2 += b2 unless b2.length == 2

      hex = "#{r2}#{g2}#{b2}"
      depth = h[1]

      @hex_codes << {hex: hex, percent: ((depth.to_f/ total_depth.to_f)*100).round(2)}
    end
    # an array of hashes containing hex code and percentage; may not need percentage
    @hex_codes
    # binding.pry
  end

# old
  # def pixelate(image)
  #   x_coordinate = 0
  #   y_coordinate = 0
  #   image.get_pixels(x_coordinate, y_coordinate, image.columns, image.rows)
  # end

  # def collect_frequencies(pixelated_image)
  #   frequencies = Hash.new(0)
  #
  #   pixelated_image.each do |pixel|
  #     frequencies[pixel.to_color] += 1
  #   end
  #
  #   frequencies
  # end

  # def sort_frequencies(frequencies)
  #   # Sort frequencies by frequency:
  #   # # => { 109 => [red, blue, green], 5 => [yellow, black]}
  #   sorted_frequencies = frequencies.group_by{ |color, pixel_count| pixel_count }
  #
  #   # based on sorted_frequencies, turn keys into an array, select maximum of 5 largest keys
  #   top_five_keys = sorted_frequencies.keys.sort.pop(5).reverse
  #
  #   # create empty pixel_colors array to store 5 most commonly occuring pixel colors
  #   pixel_colors = []
  #
  #   # until pixel_colors.length == 5, push values accessed from sorted_frequencies
  #   top_five_keys.each do |key|
  #     colors_array = sorted_frequencies[key]
  #     colors_array.each { |color| pixel_colors.push(color[0]) }
  #   end
  #
  #   # Keep only the top 5 colors (in case a key was associated with more than 1 color)
  #   pixel_colors.shift(5)
  # end

end
