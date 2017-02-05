class WelcomeController < ApplicationController

    def index
        images = []
        @images = generate_image_colors(create_image_array(images))
    end

    private

    def generate_image_colors(images)
        number_of_colors = 12
        number_of_dominant_colors = 5
        images.each do |image|
            image[:colors] = []
            pixelated_image = pixelate(image[:path], number_of_colors)
            frequencies = collect_frequencies(pixelated_image)
            sorted_frequencies = sort_frequencies(frequencies)
            image[:colors] = top_colors(sorted_frequencies)
            #   total_pixel_count = quantized_image.columns * quantized_image.rows
            #   colors = get_hex(image[:path], number_of_colors, total_pixel_count)
            #   colors = colors.sort_by {|color| color[:percent]}.reverse
            #   colors.each {|hex_code| image[:colors] << hex_code[:hex]}
            #   image[:colors] =  image[:colors].shift(number_of_dominant_colors)
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

    def pixelate(path, number_of_colors)
        image = Magick::Image.read(path).first
        quantized_image = image.quantize(number_of_colors, Magick::RGBColorspace)
        # resize
        resized_image = quantized_image.resize(0.25)
        # pixelate
        pixelated_image = resized_image.get_pixels(0, 0, resized_image.columns, resized_image.rows)
    end

    # def sort_color_histogram(path, number_of_colors)
    #   quantized_image = quantize_image(path, number_of_colors)
    #   sorted_histogram = quantized_image.color_histogram.sort {|color, frequency| frequency[1] <=> color[1]}
    #   binding.pry
    # end

    def collect_frequencies(pixelated_image)
        frequencies = Hash.new 0
        pixelated_image.map {|pixel| frequencies[pixel.to_color] += 1}
        frequencies
    end

    def sort_frequencies(frequencies)
        sorted = frequencies.sort_by{|_, frequency| frequency}
        sorted.reverse
    end

    def top_colors(sorted_frequencies)
        top_five = sorted_frequencies.pop(5)
        top_five.reverse
    end

    def get_hex(sorted_frequencies)
      @hex_codes = []
    #   sorted_histogram = sort_color_histogram(path, number_of_colors)

      sorted_histogram.count.times do |i|
        h = sorted_histogram[i]
        r1 = h[0].red/255
        g1 = h[0].green / 255
        b1 = h[0].blue / 255

        r2 = r1.to_s(16)
        g2 = g1.to_s(16)
        b2 = b1.to_s(16)

        r2 += r2 unless r2.length == 2
        g2 += g2 unless g2.length == 2
        b2 += b2 unless b2.length == 2

        hex = "#{r2}#{g2}#{b2}"

        # pixel_count = h[1]
        # pixel_percent = ((pixel_count.to_f/ total_pixel_count.to_f)*100).round(2)

        @hex_codes << {hex: hex}
      end
      @hex_codes

    end

end
