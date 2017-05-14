event :validate_editor, :validate, on: :save do
  # block not author editing except bot?
  if real? && (creator.id != Auth.current_id || Auth.current_id == WagnBotID)
    errors.add :text, " can only be edited by author"
  end
end

format :html do
  view :editor do |args|
    # if not the author, don't show the editor
    if !card.real? || card.creator.id == Auth.current_id
      arity = method(__method__).super_method.arity
      arity.zero? ? super() : super(args)
    else
      link = link_to_card card.creator
      %{Only #{link}(author) can edit this text source.}
    end
  end
end
