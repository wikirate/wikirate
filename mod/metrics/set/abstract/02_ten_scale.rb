format :html do
  # needed for ten-scale display of values of non-ten-scale metrics
  # (eg Formulae used in WikiRating)
  view :ten_scale, unknown: true do
    wrap_with :span, class: "metric-value" do
      beautify_ten_scale(card.value).html_safe
    end
  end

  def beautify_ten_scale value
    colorify value
  end

  def clean_ten_scale value
    if value.number?
      ten_scale_decimal value.to_f
    elsif Answer.unknown? value
      "?"
    else
      "!"
    end
  end

  def ten_scale_decimal value
    number_with_precision value, precision: (value >= 10 ? 0 : 1)
  end

  def colorify value, mono=false
    return "" if value.blank?
    haml :colorify, value: value, mono: mono
  end

  private

  def color_class value, mono
    return "light-color-0" unless value.number?

    "#{mono ? :mono : :multi}-color-#{color_integer value}"
  end

  def color_integer value
    value = value.to_i
    if value.negative?
      0
    elsif value > 9
      9
    else
      value
    end
  end
end
