format :html do
  # table with existing values
  # and source side for adding new values
  view :research_answer do
    # voo.show! :answer_form
    voo.editor = :inline_nests
    frame do
      render_haml :research_answer
    end
  end

  # slot for the form
  view :new_answer, cache: :never do
    wrap do
      _optional_render :answer_form
    end
  end

  view :answer_form do
    nest new_answer_card, view: :table_form
  end

  def new_answer_card
    card.attach_subfield "replace with year", type_id: MetricValueID
  end

  def view_template_path view
    super(view, __FILE__)
  end
end
