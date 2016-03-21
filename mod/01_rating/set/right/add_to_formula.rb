def virtual?
  true
end

def split_metrics
  metric_parts = cardname.parts.size - 1
  (metric_parts - 1).downto(1) do |split|
    next unless (l = self[0..split]) && l.type_id == MetricID &&
                (r = self[split+1..metric_parts-1]) && r.type_id == MetricID
    return l, r
  end
end

format :html do
  view :core do |args|
    input_metric, formula_metric = card.split_metrics
    subformat(input_metric).render_add_to_formula(args) +
    %{
    <hr>
     <div class="row clearfix">
      <div class="data-item text-center">
        #{add_metric_link(input_metric, formula_metric)}
      </div>
    </div>
    }

  end

  def add_metric_link input_metric, formula_metric
    variables_card = formula_metric.formula_card.variables_card
    card_link variables_card,
              text: 'Add this metric',
              class: 'button button-primary close-modal slotter',
              'data-slot-selector' =>
                ".TYPE_PLUS_RIGHT-metric-formula.edit-view .RIGHT-Xvariable[data-card-name='#{variables_card.name}']",
              remote: true,
              path_opts: {
                action: :update, add_item: input_metric.cardname.key,
              }
  end
end
