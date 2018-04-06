format :html do
  view :missing do
    handle_edit_general_overview { super() }
  end

  view :core do
    handle_edit_general_overview { super() }
  end

  # used in analysis page
  view :titled_with_edits do
    handle_edit_general_overview { super() }
  end

  def default_param_key
    :edit_general_overview
  end

  view :editor do
    return super() unless params[default_param_key] && card.ok?(:update)
    prompt = with_nest_mode :normal do
      claim_name = params[:citable]
      if claim_name && (claim = Card[claim_name])
        nest claim, view: :sample_citation
      else
        render! :citation_tip
      end
    end
    %( #{prompt}#{super()} )
  end

  view :citation_tip, tags: :unknown_ok do
    tip = " easily cite this note by pasting the following: "\
          "#{text_area_tag('sample-citation-textarea')}"
    %( <div class="sample-citation">#{tip tip}</div> )
  end

  def tip tip
    return "" unless Auth.signed_in? && tip && @mode != :closed
    %(
        <div class="note-tip">
          Tip: You can #{tip}
          <span id="close-tip" class="fa fa-times-circle"></span>
        </div>
      )
  end

  view :tip do
    tip next_step_tip
  end

  def handle_edit_general_overview
    if params[default_param_key] && card.ok?(:update)
      render! :edit
    else
      yield
    end
  end
end
