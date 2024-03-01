format :html do
  view :result_bar do
    voo.show! :type_badge
    prepare_bar [9, 3], [6, 3, 3]
    class_up "bar-middle", "align-items-center", :nests
    build_bar
  end

  view :bar_middle do
    result_middle { super() }
  end

  view :type_badge do
    type = card.type_name
    link_to_card type, nil, class: "badge bg-#{type.key}" # " _over-card-link"
  end

  def result_middle
    voo.explicit_show?(:type_badge) ? render_type_badge : yield
  end
end
