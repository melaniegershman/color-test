class WelcomeController < ApplicationController
  NUMBER_OF_IMAGES = 15
  def index
    collect_frequencies_of_images(NUMBER_OF_IMAGES)
    @number = 15.times {|_| _ += 1 }
    p @colors
  end

  private

  def collect_frequencies_of_images(number_of_images)
    @colors = []
    number_of_images.times do |number|
      path = "app/assets/images/#{number}.jpg"
      image = load_image(path)
      frequencies = collect_frequencies(image)
      sorted_frequencies = sort_frequencies(frequencies)
      @colors << top_colors(sorted_frequencies)
    end
    @colors
  end

  def load_image(path)
     Magick::Image.read(path).first
  end

  def collect_frequencies(image)
    frequencies = Hash.new(0)

    pixels = pixelate(image)

    pixels.map do |pixel|
      frequencies[pixel.to_color] += 1
    end

    frequencies
  end

  def pixelate(image)
    x_coordinate = 0
    y_coordinate = 0
    image.get_pixels(x_coordinate, y_coordinate, image.columns, image.rows)
  end

  def sort_frequencies(frequencies)
    sorted = frequencies.sort_by {|_, frequency| frequency}
    sorted.reverse
  end

  def top_colors(sorted_frequencies)
    sorted_frequencies[0..4]
  end


end
