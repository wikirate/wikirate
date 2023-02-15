format do
  # this is just to add the unknown setting, which was (perhaps unintentionally?)
  # set globally in wikirate before.  removing the setting has some surprising
  # consequences
  view :core, unknown: true do
    super()
  end
end

format :html do
  view :nav_arrows, template: :haml

  def section_header blurb
    right_side = block_given? ? yield : nil
    haml :section_header, blurb: blurb, right_side: right_side
  end

  def absolutize_edit_fields fields
    fields.map { |cardname| [cardname, { absolute: true }] }
  end
end
