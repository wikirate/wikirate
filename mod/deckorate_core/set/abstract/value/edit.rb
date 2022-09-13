format :html do
  # When editing +value cards, whether independently or within a form,
  # there is an "unknown" field, which is implemented as a card but never stored.

  # The check request card, which is a field of the answer, is also connected
  # to the value form.  (Note: it should probably either be moved to a field
  # of the value or moved out of the +value form.

  view :input do
    super() + unknown_checkbox
  end

  def unknown_checkbox
    haml :unknown_checkbox
  end
end
