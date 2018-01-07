# The answer table refresh happens on the act card.
# That can cause problem if this is not the act card.
# To be safe we count before the update
event :award_answer_create_badges, :finalize,
      on: :create,
      after: :create_answer_lookup_entry_due_to_value_change,
      when: :metric_awards_answer_badges? do
  [:general, :designer, :company].each do |affinity|
    award_create_badge_if_earned affinity
  end
  project_cards.each do |pc|
    award_create_badge_if_earned :project, pc
  end
end

def metric_awards_answer_badges?
  researched?
end

def award_create_badge_if_earned affinity, project_card=nil
  # the actions of the current act are not included
  # because we do this search before the answer table update
  affinity_name = affinity_name(affinity, project_card)
  #ActManager.act_card.act_badge_count_step affinity, affinity_name

  count = action_count(:create, affinity, project_card) # +
          # ActManager.act_card.act_badge_count(affinity, affinity_name)
  return unless (badge = earns_badge(:create, affinity, count))
  badge_card = fetch_badge_card badge, affinity, project_card
  award_badge badge_card
end

def affinity_name affinity, project_card=nil
  case affinity
  when :designer
    metric_card.metric_designer
  when :company
    company
  when :metric
    metric
  when :project
    project_card.name
  end
end

def create_count restriction={}
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

def action_count action, affinity=nil, project_card=nil
  method_name = [action, "count", affinity].compact.join "_"
  if project_card
    send method_name, project_card
  else
    send method_name
  end
end

# @return badge name if count equals its threshold
def earns_badge action, affinity_type=nil, count=nil
  badge_squad.earns_badge action, affinity_type, count
end

def fetch_badge_card badge_name, affinity=nil, project_card=nil
  if affinity
    badge_name = affinity_badge_name badge_name, affinity, project_card
  end
  super badge_name
end

def affinity_badge_name badge_name, affinity, project_card=nil
  return badge_name if affinity == :general
  prefix =
    case affinity
    when :designer
      metric_card.metric_designer
    when :company
      company
    when :project
      project_card.name
    end
  "#{prefix}+#{badge_name}+#{affinity} badge"
end
