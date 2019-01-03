VALID_DESIGNER_TYPE_IDS = [ResearchGroupID, UserID, WikirateCompanyID].freeze

# The new metric form has a title and a designer field instead of a name field
# We compose the card's name here
event :set_metric_name, :initialize, on: :create, when: :needs_name? do
  title = (tcard = remove_subfield(:title)) && tcard.content
  designer = (dcard = remove_subfield(:designer)) && dcard.content
  self.name = "#{designer}+#{title}"
end

# for override
def needs_name?
  !name.present?
end

event :ensure_designer, :validate, on: :save, changed: :name do
  return if valid_designer?
  if (card = Card[metric_designer])
    errors.add :metric_designer, "invalid type #{card.type_name}"
  else
    attach_subcard metric_designer, type_id: ResearchGroupID
  end
end

def valid_designer?
  Card.fetch_type_id(metric_designer).in? VALID_DESIGNER_TYPE_IDS
end

event :ensure_title, :validate, on: :save, changed: :name do
  case Card.fetch_type_id(metric_title)
  when MetricTitleID, ReportTypeID
    return
  when nil
    attach_subcard metric_title, type_id: MetricTitleID
  else
    errors.add :metric_title, "#{metric_title} is a #{Card[metric_title].type_name} "\
                              "card and can't be used as metric title"
  end
end

event :ensure_two_parts, :validate, changed: :name do
  errors.add :name, "at least two parts are required" if name.parts.size < 2
end

event :silence_metric_deletions, :initialize, on: :delete do
  @silent_change = true
end

event :delete_all_answers, :prepare_to_validate, on: :update, trigger: :required do
  if Card::Auth.always_ok? # TODO: come up with better permissions scheme for this!
    metric_answer_cards.each { |answer_card| delete_as_subcard answer_card }
  else
    errors.add :answers, "only admins can delete all answers"
  end
end
