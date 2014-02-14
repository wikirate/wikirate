
view :edit_in_form do |args|
  with_inclusion_mode :normal do
    content = _render_content args
    
    if card.new_card?
      content += form_for_multi.hidden_field(:content)
    end

    content
  end
end



