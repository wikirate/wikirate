format :html do
  view :content do |args|
    handle_edit_general_overview( args ) { super args }
  end

  view :missing do |args|
    handle_edit_general_overview( args ) { super args }
  end

  view :titled_with_edits do |args|
    handle_edit_general_overview( args ) { super args }
  end

  view :editor do |args|
    # if claim_name = params[:citable] and claim = Card[claim_name]
      prompt = with_inclusion_mode :normal do
        if claim_name = params[:citable] and claim = Card[claim_name]
          nest claim, :view=>:sample_citation
        else
          render :citation_tip
        end
      end
      %{ #{ prompt } #{ super args } }
    # else
      # super args
    # end
  end

  view :citation_tip do |_args|
    tip = 'easily cite this note by pasting the following:'+
          text_area_tag('sample-citation-textarea')
    %{ <div class="sample-citation">#{ render :tip, tip: tip }</div> }
  end

  view :tip do |args|
    # special view for prompting users with next steps
    if Auth.signed_in? &&
       (tip = args[:tip] || next_step_tip) &&
       @mode != :closed
      %{
        <div class="note-tip">
          Tip: You can #{tip}
          <span id="close-tip" class="fa fa-times-circle"></span>
        </div>
      }
    end.to_s
  end

  def handle_edit_general_overview args
    if params[:edit_general_overview] && card.ok?(:update)
      # if missing view renders core view, it will cause infinit loop
      # core -> missing -> core ... -> stack level too deep
      render :core, args unless @current_view == :missing
      render :edit, args
    else
      yield
    end
  end

end
