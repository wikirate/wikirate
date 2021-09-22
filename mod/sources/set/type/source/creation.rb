# handles source creation in the context of a given answer
#
# two key environmental parameters are involved:
# - answer -> the name of an answer card
# - source_search_term -> a search term, eg from the "sourcebox" ui

format do
  view :conversion_error, perms: :none do
    "PDF conversion failed"
  end
end

format :html do
  view :conversion_error do
    voo.title = "Unable to create Citable Source File"
    class_up "d0-card-header", "bg-danger text-white"
    frame { haml :conversion_error }
  end

  def answer_name
    params[:answer]
  end

  def answer_card
    return unless answer_name
    Card.fetch answer_name, new: { type_id: Card::MetricAnswerID }
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
    year = answer_card.year
    year unless year == "false"
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

  # when successfully adding in a sourcebox context, refresh the whole source tab
  def new_success
    return super unless answer_name
    {
      mark: answer_name,
      type_id: card.type_id,
      view: :source_selector,
      soft_redirect: true
    }
  end

  def new_form_opts
    return super unless answer_name
    super.merge "data-slot-selector": ".source_selector-view"
  end
end
