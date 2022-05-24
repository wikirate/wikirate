def flag_names
  super << :calculated
end

def calculated_flag
  if !card.calculated?
    ""
  elsif card.researched_value?
    overridden_flag_icon
  else
    calculated_flag_icon
  end
end

def calculated_flag_icon
  fa_icon :calculator, title: "Calculated answer", class: "text-success"
end

def overridden_flag_icon
  wrap_with :span, class: "overridden-icon", title: "Overridden calculated answer" do
    [fa_icon(:user), fa_icon(:calculator, class: "text-danger")]
  end
end
