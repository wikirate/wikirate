# the following is WIP code developed for the single-use script fashion_merge.rb.
# It is not ready for primetime.

format :html do
  delegate :as_moderator?, to: :card

  view :merge, cache: :never, template: :haml, perms: :as_moderator?

  view :merge_form, cache: :never, perms: :as_moderator? do
    wrap do
      card_form :update, success: { view: :merge_success } do
        [
          hidden_tags(card: { trigger_in_action: :merge_companies }),
          render_target_company_select,
          render_merge_button
        ]
      end
    end
  end

  view :merge_button do
    submit_button text: "Begin Merge",
                  "data-confirm": "You're sure about this, right?",
                  class: "my-2"
  end

  view :target_company_select do
    select_tag :target_company, "",
               class: "form-control",
               data: { "options-card": :company.cardname }
  end

  view :engage_tab do
    return super() unless as_moderator?

    [super(), haml(:merge_link)]
  end

  view :merge_success do
    wrap_with :div, class: "alert-success p-3" do
      "Success. This completes the automated portion of the merge process. " \
      "See below to continue merging #{render_link} " \
      "into #{link_to_card Env.params[:target_company]}."
    end
  end
end

event :merge_companies, :validate, trigger: :required do
  return unless ok_to_merge?
  if (target = Env.params[:target_company])&.present?
    merge_into target
  else
    errors.add :content, "target company required"
  end
end

def ok_to_merge?
  as_moderator? ? true : deny_because("Only moderators can merge companies")
end

def merge_into target_company
  target_company = target_company.cardname
  move_relationships_to target_company
  move_answers_to target_company
  move_dataset_listings_to target_company
  move_group_listings_to target_company
  move_source_listings_to target_company
  move_field_cards_to target_company
end

def move_relationships_to target_company
  relationships.each do |relationship|
    relationship.move company: target_company
  end
  inverse_relationships.each do |inverse_relationship|
    inverse_relationship.move related_company: target_company
  end
end

def move_answers_to target_company
  answers.each do |answer|
    if answer.real?
      answer.move company: target_company
    else
      answer.delete
    end
  end
end

def move_dataset_listings_to target_company
  replace_company_listings :dataset, target_company do |comp_proj|
    Card[comp_proj.right] # each item is <company>+<dataset>
  end
end

def move_group_listings_to target_company
  replace_company_listings :company_group, target_company do |company_group|
    group_card = Card[company_group]
    group_card.specification_card.explicit? ? group_card : nil
  end
end

def move_source_listings_to target_company
  replace_company_listings(:source, target_company) { |source| Card[source] }
end

def move_field_cards_to target_company
  simple_field_cards.each do |field_card|
    new_name = field_card.name.swap name, target_company
    next if Card.exist? new_name
    field_card.update! name: new_name
  end
end

def replace_company_listings trait, target_company
  fetch(trait).item_names.each do |trt|
    next unless (base = yield trt)

    replace_company_in_list base, target_company
  end
end

def replace_company_in_list base, target_company
  list = base.fetch :company
  list.drop_item name
  list.add_item target_company
  list.save
end
