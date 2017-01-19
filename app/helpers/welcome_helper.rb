module WelcomeHelper
  def hexify(padded_code)
    color = padded_code
    color = color[1...color.length].chars
    unique_hex = "#" + color.each_slice(2).to_a.uniq.join
  end
end
