format :html do
  view :content do |args|
    if params[:edit_article] && card.ok?(:update)
      render :edit, args
    else
      super args
    end
  end
  
  
  view :editor do |args|
    if claim_name = params[:citable] and claim = Card[claim_name]
      prompt = with_inclusion_mode :normal do
        nest claim, :view=>:sample_citation
      end
      %{#{ super args } #{prompt} }
    else
      super args
    end
  end
end