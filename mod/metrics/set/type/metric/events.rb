
event :ensure_designer, :prepare_to_store, on: :save, changed: :name do
  return if valid_designer?
  if (card = Card[metric_designer])
    errors.add :metric_designer, "invalid type #{card.type_name}"
  else
    attach_subcard metric_designer, type_id: ResearchGroupID
  end
end

event :ensure_title, :prepare_to_store, on: :save, changed: :name do
  case Card.fetch_type_id(metric_title)
  when MetricTitleID
    return
  when nil
    attach_subcard metric_title, type_id: MetricTitleID
  else
    errors.add :metric_title, "#{metric_title} is a #{Card[metric_title].type_name} "\
                              "card and can be use as metric title"
  end
end

event :ensure_two_parts, :validate, changed: :name do
  errors.add :name, "at least two parts are required" if name.parts.size < 2
end

event :silence_metric_deletions, :initialize, on: :delete do
  @silent_change = true
end

event :update_lookup_answers, :integrate,
      on: :update, changed: :name do
  # this recalculates answers, when technically all that needs to happen is
  # for name fields to be updated.

  # FIXME: when renaming, the metric type gets confused at some point, and
  # calculated? does not correctly return true for calculated metrics
  # (which have MetricType::Researched among their singleton class's ancestors)
  # if this were working properly it could be in the when: arg.
  #
  expire
  formula_card&.regenerate_answers if refresh(true).calculated?
end
