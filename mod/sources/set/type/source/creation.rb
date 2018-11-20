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

  def new_form_opts
    return super unless answer_name
    super.merge "data-slot-selector": ".source_tab-view"
  end

  def prepopulate_answer_fields
    { year: answer_card.year,
      wikirate_company: answer_card.company,
      report_type: answer_card.report_type&.content }.each do |fieldcode, value|
      params["_#{fieldcode.cardname}"] = value
    end
   end

  def cancel_button_new_args
    return super unless answer_name
    { href: path(mark: answer_name, view: :sourcebox, type_id: MetricAnswerID) }
  end

  def new_view_hidden
    return super unless answer_name
    hidden_tags success: {
      id: answer_name, soft_redirect: true, view: :source_tab
    }
  end
end
