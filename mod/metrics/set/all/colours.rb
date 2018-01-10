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
    value = value.to_i
    value = 0 if value < 0
    value = 9 if value > 9
    "#{mono ? 'mono' : 'multi'}-color-#{value}"
  end
end
