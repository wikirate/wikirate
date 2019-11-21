# the following is WIP code developed for the single-use script fashion_merge.rb.
# It is not ready for primetime.

format :html do
  view :merge, template: :haml, perms: ->(f) { f.card.as_moderator? }

  view :merge_form, perms: ->(f) { f.card.as_moderator? } do
    wrap do
      card_form :update, success: { view: :merge_success } do
        [
          hidden_tags(card: { trigger: :merge_companies }),
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
    text_field_tag :target_company, "",
               class: "company_autocomplete form-control"
  end

  view :engage_tab do
    return super() unless card.as_moderator?

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
    abort :success
  else
    errors.add :content, "target company required"
  end
end

def ok_to_merge?
  as_moderator? ? true : deny_because("Only moderators can merge companies")
end

def merge_into target_company
  target_company = Card.fetch_name target_company
  move_all_answers_to target_company
  move_project_listings_to target_company
  move_group_listings_to target_company
  move_source_listings_to target_company
end

def move_all_answers_to target_company
  all_answers.each do |answer|
    next unless answer.real?
    answer.move company: target_company
  end
end

def move_project_listings_to target_company
  replace_company_listings :project, target_company do |comp_proj|
    Card[comp_proj.right] # each item is <company>+<project>
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

def replace_company_listings trait, target_company
  each_trait_item_name trait do |trait|
    next unless base = yield(trait)

    replace_company_in_list base, target_company
  end
end

def each_trait_item_name trait
  fetch(trait: trait).item_names.each do |item_name|
    yield item_name
  end
end

def replace_company_in_list base, target_company
  list = base.fetch trait: :wikirate_company
  list.drop_item name
  list.add_item target_company
  list.save
end
