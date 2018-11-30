event :validate_editor, :validate, on: :save do
  errors.add :text, " can only be edited by author" unless editable?
end

# only author can edit
def editable?
  real? && Auth.current_id.in?([creator.id, WagnBotID])
end

format :html do
  view :editor do
    if card.editable?
      super()
    else
      link = link_to_card card.creator
      %{Only #{link}(author) can edit this text source.}
    end
  end
end
