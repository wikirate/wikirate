include_set Abstract::AwardBadge

# The answer table refresh happens on the act card.
# That can cause problem if this is not the act card.
# To be safe we count before the update
event :award_metric_value_create_badges, before: :refresh_updated_answers,
      on: :create do
  [:general, :designer, :company].each do |type|
    count = send("create_count_general") + 1
    next unless (badge = earns_badge(count, :create, type))
    add_badge full_badge_name(badge, type), :metric_value
  end
  award_project_badges
end

event :award_metric_value_update_badges, before: :refresh_updated_answers,
      on: :update do
  count = update_count + 1
  next unless (badge = earns_badge(count, :update))
  add_badge badge
end


def award_project_badges
  project_cards.each do |pc|
    count = project_count(pc) + 1
    next unless (badge = earns_badge(:create, :project, count))
    add_badge full_badge_name(badge, :project, pc.name)
  end
end

def earns_badge count, action, affinity_type=nil
  Type::MetricValue::BadgeHierarchy.earns_badge count, action, affinity_type
end

def action_count action, restriction={}
  case action
  when :create
    create_count restriction
  end
end

def create_count restriction={}
  Answer.where(restriction.merge(creator_id: Auth.current_id)).count
end

def update_count restriction={}
  Answer.where(restriction.merge(creator_id: Auth.current_id)).count
end

def create_count_general
  create_count
end

def create_count_designer
  create_count designer_id: metric_card.metric_designer_card.id
end

def create_count_company
  create_count company_id: company_card.id
end

def create_count_project project_card
  create_count metric_id: project_card.metric_ids,
               company_id: project_card.company_ids
end

def project_cards
  Card.search type_id: ProjectID,
              right_plus: [MetricID, { refer_to: { id: metric_card.id } }],
              and: {
                right_plus: [WikirateCompanyID,
                             { refer_to: { id: company_card.id } }]
              }
end

def full_badge_name badge_name, type, project=nil
  return badge_name if type == :general
  prefix =
    case type
    when :designer
      metric_card.metric_designer
    when :company
      company
    when :project
      project
    end
  "#{prefix}+#{badge_name}+#{type} badge"
end


