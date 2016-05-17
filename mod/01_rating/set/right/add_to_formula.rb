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
    add_metric =
      <<-HTML
        <hr>
         <div class="row clearfix">
          <div class="data-item text-center">
            #{add_metric_link(input_metric, formula_metric)}
          </div>
        </div>
      HTML
    subformat(input_metric).render_add_to_formula(args) + add_metric.html_safe
  end

  def add_metric_link input_metric, formula_metric
    variables_card = formula_metric.formula_card.variables_card
    args = { class: "button button-primary" }
    if formula_metric.formula_card.wiki_rating?
      add_class args, "add-weight"
      content_tag :a, "Add this metric",
                  args.merge("data-metric-id" => input_metric.id)
    else
      args.merge! text: "Add this metric",
                 "data-slot-selector" =>
                    ".content-editor > .RIGHT-Xvariable[data-card-name='#{variables_card.name}']",
                  remote: true,
                  path_opts: {
                    action: :update, add_item: input_metric.cardname.key,
                  }
      add_class args, "close-modal slotter"
      card_link variables_card, args
    end
  end
end
