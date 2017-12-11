event :process_sources, :prepare_to_validate,
      on: :save, when: :standard? do
  if (sources = subfield(:source))
    sources.item_names.each do |source_name|
      if Card.exists? source_name
        add_report_type source_name
        add_company source_name
      else
        errors.add :source, "#{source_name} does not exist."
      end
    end
  elsif action == :create
    errors.add :source, "no source cited"
  end
end

def source_subcards new_source_card
  [new_source_card.subfield(:file), new_source_card.subfield(:text),
   new_source_card.subfield(:wikirate_link)]
end

def source_in_request?
  sub_source_card = subfield("source")
  return false if sub_source_card.nil? ||
                  sub_source_card.subcard("new_source").nil?
  new_source_card = sub_source_card.subcard("new_source")
  source_subcard_exist?(new_source_card)
end

def source_subcard_exist? new_source_card
  file_card, text_card, link_card = source_subcards new_source_card
  file_card&.attachment.present? ||
    text_card&.content.present? ||
    link_card&.content.present?
end

def add_report_type source_name
  if report_type
    report_names = report_type.item_names
    source_card = Card.fetch(source_name).fetch trait: :report_type, new: {}
    report_names.each do |report_name|
      source_card.add_item report_name
    end
    add_subcard source_card
  end
end

def add_company source_name
  source_card = Card.fetch(source_name).fetch trait: :wikirate_company, new: {}
  source_card.add_item company_name
  add_subcard source_card
end

def report_type
  metric_card.fetch trait: :report_type
end

format :html do
  def source_form_url
    path action: :new, mark: :source, preview: true, company: card.company
  end

  def source
    Env.params[:source]
  end

  def sources
    @sources ||= find_potential_sources - card.source_card.item_cards
    if source && (source_card = Card[source])
      @sources.push(source_card)
    end
    @sources
  end

  def source_suggestions
    @potential_sources ||= find_potential_sources
  end

  def find_potential_sources
    Card.search(
      type_id: Card::SourceID,
      right_plus: [["company", { refer_to: card.company }],
                   ["report_type", {
                     refer_to: {
                       referred_to_by: card.metric + "+report_type"
                     }
                   }]]
    )
  end

  view :source_suggestions, cache: :never do
    wrap_with :div, source_list(source_suggestions).html_safe,
              class: "relevant-sources" do
    end
  end

  view :relevant_sources, cache: :never do
    wrap_with :div, source_list.html_safe, class: "relevant-sources form-group"
  end

  def source_list source_cards=sources
    return "None" if source_cards.empty?
    source_cards.map do |source|
      with_nest_mode :normal do
        subformat(source).render_relevant
      end
    end.join("")
  end
end
