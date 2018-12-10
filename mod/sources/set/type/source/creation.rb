# handles source creation in the context of a given answer
#
# two key environmental parameters are involved:
# - answer -> the name of an answer card
# - source_search_term -> a search term, eg from the "sourcebox" ui

format :html do
  def answer_name
    params[:answer]
  end

  def answer_card
    return unless answer_name
    Card.fetch answer_name, new: { type_id: MetricAnswerID }
  end

  before :new do
    voo.hide! :new_type_formgroup
    prepopulate_answer_fields if answer_name
  end

  # uses "shorthand" parameters to set fields that can be gleaned from
  # an answer and/or search term
  def prepopulate_answer_fields
    %i[year wikirate_company report_type wikirate_title description].each do |fieldcode|
      next unless (value = send "default_#{fieldcode}")
      params["_#{fieldcode.cardname}"] = value
    end
  end

  def default_year
    answer_card.year
  end

  def default_wikirate_company
    answer_card.company
  end

  def default_report_type
    answer_card.report_type&.content
  end

  def default_wikirate_title
    metadata&.title
  end

  def default_description
    metadata&.description
  end

  # uses LinkThumbnailer to attempt to derive title and description from search term.
  def metadata
    term = source_search_term.to_s
    return unless term&.url?
    @metadata ||= Self::Source::MetaData.new(term)
  end

  def source_search_term
    Env.params[:source_search_term]
  end

  # when cancelling in a sourcebox context, refresh the sourcebox slot
  def cancel_button_new_args
    return super unless answer_name
    { href: path(mark: answer_name, view: :sourcebox, type_id: MetricAnswerID),
      "data-slot-selector": ".sourcebox-view" }
  end

  # when successfully adding in a sourcebox context, refresh the whole source tab
  def new_view_hidden
    return super unless answer_name
    hidden_tags success: {
      id: answer_name, soft_redirect: true, view: :source_selector
    }
  end

  def new_form_opts
    return super unless answer_name
    super.merge "data-slot-selector": ".source_selector-view"
  end

  def freshen_path
    path mark: root.card.name,
         view: :source_selector,
         source_search_term: card.link_url,
         freshen_source: true
  end

  def freshen_title
    "Create new source from updated webpage: #{card.link_url}."
  end
end
