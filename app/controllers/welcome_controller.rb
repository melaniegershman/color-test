require 'benchmark'

class WelcomeController < ApplicationController
  IMAGES = []

  def index
    @images = []
    @images = create_image_array(@images)
    @images = generate_image_colors(@images)
  end

  private

  def generate_image_colors(images)
    number_of_colors = 12
    images.each do |image|
      image[:colors] = []
      quantized_image = quantize_image(image[:path], number_of_colors)
      total_pixel_count = quantized_image.columns * quantized_image.rows
      colors = get_hex(image[:path], number_of_colors, total_pixel_count)
      colors = colors.sort_by {|color| color[:percent]}.reverse

      colors.each {|hex_code| image[:colors] << hex_code[:hex]}
      image[:colors] =  image[:colors].shift(5)
    end
    images
  end

  def create_image_array(images)
    image_directory = "app/assets/images"

    Dir.foreach(image_directory) do |image|
      image_object = {}
      if image.include?(".jpg")
        image_object[:filename] = image
        image_object[:path] = image_directory + "/" + image
        images << image_object
      end
    end
    images

  end

  def quantize_image(path, number_of_colors)
    image = Magick::Image.read(path).first
    quantized_image = image.quantize(number_of_colors, Magick::RGBColorspace)
  end

  def sort_color_histogram(path, number_of_colors)
    quantized_image = quantize_image(path, number_of_colors)
    sorted_histogram = quantized_image.color_histogram.sort {|color, frequency| frequency[1] <=> color[1]}
  end

  def get_hex(path, number_of_colors, total_pixel_count)
    @hex_codes = []
    sorted_histogram = sort_color_histogram(path, number_of_colors)

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

      pixel_count = h[1]
      pixel_percent = ((pixel_count.to_f/ total_pixel_count.to_f)*100).round(2)

      @hex_codes << {hex: hex, percent: pixel_percent}
    end
    @hex_codes

  end

end
