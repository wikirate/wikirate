format :html do
  def multi_colour
    # Gradient generated from this url
    # https://gka.github.io/palettes
    # /#colors=,red,orange,yellow,green|steps=10|bez=1|coL=0
    [
      "#ff0000",
      "#ff5700",
      "#ff7e00",
      "#fc9b00",
      "#f1b000",
      "#debd00",
      "#c2c000",
      "#9ab700",
      "#65a300",
      "#008000"
    ]
  end

  def mono_colour
    # Gradient generated from this url
    # https://gka.github.io/palettes/
    # #colors=CornflowerBlue,LightSteelBlue|steps=10|bez=1|coL=1
    [
      "#6495ed",
      "#6f9aeb",
      "#799fea",
      "#82a4e8",
      "#8aa9e7",
      "#93afe5",
      "#9ab4e3",
      "#a2b9e2",
      "#a9bfe0",
      "#b0c4de"
    ]
  end

  def colorify value, mono=false
    return "" if value == ""
    colour = pick_colour(value, mono)
    wrap_color_div(value, colour)
  end

  def pick_colour value, mono
    value = value.to_f.ceil
    colours = mono ? mono_colour : multi_colour
    return colours[0] if value <= 1
    return colours[9] if value >= 10
    colours[value - 1]
  end

  def wrap_color_div value, colour
    color = "color:" + colour
    square_icon = wrap_with(:i, "", class: "fa fa-square ", style: color)
    value = wrap_with(:span, value)
    wrap_with :div, class: "range-value" do
      [
        value,
        square_icon
      ]
    end
  end
end
