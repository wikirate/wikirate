format :html do
  view :nav_arrows, template: :haml

  def section_header blurb, button={}
    haml :section_header, blurb: blurb, button: button, yielded: (yield if block_given?)
  end

  def absolutize_edit_fields fields
    fields.map { |cardname| [cardname, { absolute: true }] }
  end
end
