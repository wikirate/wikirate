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
    if value.number?
      "#{mono ? "mono" : "multi"}-color-#{normalize_value value}"
    else
      "light-color-0"
    end
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
