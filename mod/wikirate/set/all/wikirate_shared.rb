format do
  # this is just to add the unknown setting, which was (perhaps unintentionally?)
  # set globally in wikirate before.  removing the setting has some surprising
  # consequences
  view :core, unknown: true do
    super()
  end

  def social_media_links
    {
      "Facebook" => "https://www.facebook.com/wikirate/",
      "Twitter" => "https://twitter.com/WikiRate",
      "Instagram" => "https://www.instagram.com/wikirate/",
      "LinkedIn" => "https://www.linkedin.com/company/wikirate"
    }
  end
end

format :html do
  view :nav_arrows, template: :haml

  def section_header blurb, button={}
    haml :section_header, blurb: blurb, button: button
  end

  def absolutize_edit_fields fields
    fields.map { |cardname| [cardname, { absolute: true }] }
  end
end
