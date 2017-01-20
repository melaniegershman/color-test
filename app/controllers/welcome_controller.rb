require 'benchmark'

class WelcomeController < ApplicationController
  NUMBER_OF_IMAGES = 15
  def index
    collect_frequencies_of_images(NUMBER_OF_IMAGES)
    p @images
  end

  private

  def collect_frequencies_of_images(number_of_images)
    @images = []

    number_of_images.times do |number|
      path = "app/assets/images/#{number}.jpg"
      image = load_image(path)

      # Resize
      # image = image.resize(0.3)

      # binding.pry

      # Pixelating
      # less than 0.01 seconds
      pixelated_image = pixelate(image)

      # binding.pry
      # takes 3 seconds
      frequencies = collect_frequencies(pixelated_image)

      # below: less than 0.01 seconds
      @images << sort_frequencies(frequencies)
    end

    @images
  end

  def load_image(path)
     Magick::Image.read(path).first
  end

  def pixelate(image)
    x_coordinate = 0
    y_coordinate = 0
    image.get_pixels(x_coordinate, y_coordinate, image.columns, image.rows)
  end

  def collect_frequencies(pixelated_image)
    frequencies = Hash.new(0)

    pixelated_image.each do |pixel|
      frequencies[pixel.to_color] += 1
    end

    frequencies
  end

  def sort_frequencies(frequencies)
    # Sort frequencies by frequency:
    # # => { 109 => [red, blue, green], 5 => [yellow, black]}
    sorted_frequencies = frequencies.group_by{ |color, pixel_count| pixel_count }

    # based on sorted_frequencies, turn keys into an array, select maximum of 5 largest keys
    top_five_keys = sorted_frequencies.keys.sort.pop(5).reverse

    # create empty pixel_colors array to store 5 most commonly occuring pixel colors
    pixel_colors = []

    # until pixel_colors.length == 5, push values accessed from sorted_frequencies
    top_five_keys.each do |key|
      colors_array = sorted_frequencies[key]
      colors_array.each { |color| pixel_colors.push(color[0]) }
    end

    # Keep only the top 5 colors (in case a key was associated with more than 1 color)
    pixel_colors.shift(5)
  end

end
