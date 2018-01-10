format :html do
  def colorify value, mono=false
    return "" if value == ""
    color_class = number?(value) ? pick_color(value, mono) : "light-color-0"
    wrap_color_div(value, color_class)
  end

  def pick_color value, mono
    value = value.to_f.ceil
    color_css = mono ? "mono-color-" : "multi-color-"
    return color_css + "0" if value <= 1
    return color_css + "9" if value >= 10
    [color_css,value - 1].join
  end

  def wrap_color_div value, color
    css_classes = "fa fa-square " + color
    square_icon = wrap_with(:i, "", class: css_classes)
    value = wrap_with(:span, value)
    wrap_with :div, class: "range-value" do
      [
        value,
        square_icon
      ]
    end
  end

  def number? str
    true if Float(str)
  rescue
    false
  end
end
