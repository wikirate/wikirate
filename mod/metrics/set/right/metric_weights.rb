event :update_formula, :prepare_to_store do
  new_formula = item_names.map do |i_name|
    weight = Env.params[i_name] || 0
    "{{#{i_name}}}*#{weight}"
  end.join "+"
  add_subcard "#{name.left}+#{Card[:formula].name}", content: new_formula
end

def formula
  left.formula
end

def metrics_with_weight
  formula.split("+").map do |summand|
    metric, weight = summand.split "*"
    metric, weight = weight, metric if weight.match?(/[^\s\d\.]/)
    metric = metric.scan(/\{\{([^}]+)\}\}/).flatten.first
    weight = weight.to_f
    [metric, weight]
  end
end

format :html do
  # view :list_item do
  #   <<-HTML
  #   <li class="pointer-li">
  #     <div class="input-group">
  #       <div class="input-group-prepend handle">
  #         <span class="input-group-text">
  #           #{glyphicon 'option-vertical left'}
  #           #{glyphicon 'option-vertical right'}
  #         </span>
  #       </div>
  #       #{text_field_tag 'pointer_item', args[:pointer_item],
  #                        class: 'pointer-item-text form-control'}
  #
  #       <div class="input-group-append">
  #         <button class="pointer-item-delete btn btn-outline-secondary" type="button">
  #           #{glyphicon 'remove'}
  #         </button>
  #       </div>
  #       </div>
  #     </li>
  #   HTML
  # end

  view :editor do
    metrics_with_weight.map do |_metric, _weight|
      metric_slider
    end.join ""
  end

  def metric_slider metric_name, weight
    %(
      #{metric_name}
      #{weight}
    )
  end
end
