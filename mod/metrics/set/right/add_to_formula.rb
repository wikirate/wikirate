def virtual?
  true
end

def split_metrics
  metric_parts = cardname.parts.size - 1
  (metric_parts - 1).downto(1) do |split|
    next unless (l = self[0..split]) && l.type_id == MetricID &&
                (r = self[split + 1..metric_parts - 1]) && r.type_id == MetricID
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
    args = { class: "button button-primary" }
    link_text = "Add this metric"
    if formula_metric.formula_card.wiki_rating?
      add_class args, "_add-weight"
      wrap_with :a, link_text, args.merge("data-metric-id" => input_metric.id)
    else
      varcard = formula_metric.formula_card.variables_card
      editor_selector =
        ".content-editor > .RIGHT-Xvariable[data-card-name='#{varcard.name}']"
      add_class args, "close-modal slotter"
      link_to_card varcard, link_text, args.merge(
        remote: true, known: true, "data-slot-selector" => editor_selector,
        path: { action: :update, add_item: input_metric.cardname.key }
      )
    end
  end
end
