event :validate_editor, :after=>:approve, :on=>:save do 

  # block not author editing except bot?
  if real? and ( creator.id != Card::Auth.current_id or Card::Auth.current_id == Card::WagnBotID )
    errors.add :text, " can only be edited by author"   
  end
end

format :html do
  view :editor do |args|
    #if not the author, don't show the editor  
    if !card.real? or card.creator.id == Card::Auth.current_id 
      super(args)
    else
      %{Only #{card_link(card.creator,:text=>card.creator.name)}(author) can edit this text source.}
    end
  end
end