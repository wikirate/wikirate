format :html do
  def colorify value, mono=false
    return "" if value.blank?
    wrap_with :div, class: "range-value" do
      [
        wrap_with(:span, value),
        fa_icon(:square, color_class(value, mono))
      ]
    end
  end

  def color_class value, mono
    return "light-color-0" unless value.number?
    value = normalize_value value
    prefix = mono ? 'mono' : 'multi'
    "#{prefix}-color-#{value}"
  end

  def normalize_value value
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
