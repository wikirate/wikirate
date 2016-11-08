event :validate_editor, :validate, on: :save do
  # block not author editing except bot?
  if real? && (creator.id != Auth.current_id || Auth.current_id == WagnBotID)
    errors.add :text, " can only be edited by author"
  end
end

format :html do
  view :editor do
    # if not the author, don't show the editor
    if !card.real? || card.creator.id == Auth.current_id
      super()
    else
      link = link_to_card card.creator
      %{Only #{link}(author) can edit this text source.}
    end
  end
end
