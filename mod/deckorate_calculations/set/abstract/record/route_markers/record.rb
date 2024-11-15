format :html do
  def route_marker
    overridden_value? ? overridden_marker_icon : super
  end

  def overridden_marker_icon
    wrap_with :span, class: "overridden-icon", title: "Overridden calculated answer" do
      [icon_tag(:user), icon_tag(:calculator, class: "text-danger")]
    end
  end
end
