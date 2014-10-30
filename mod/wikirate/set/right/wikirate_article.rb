format :html do
  view :content do |args|
    handle_edit_article( args ) { super args }
  end
  
  view :missing do |args|
    handle_edit_article( args ) { super args }    
  end
  
  view :titled_with_edits do |args|
    handle_edit_article( args ) { super args }    
  end  

  view :editor do |args|
    if claim_name = params[:citable] and claim = Card[claim_name]      
      prompt = with_inclusion_mode :normal do
        nest claim, :view=>:sample_citation
      end
      %{ #{ prompt } #{ super args } }
    else
      super args
    end
  end
  
  def handle_edit_article args
    if params[:edit_article] && card.ok?(:update)
      render :edit, args
    else
      yield
    end
  end
  
end