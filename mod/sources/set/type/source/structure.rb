format :html do
  before :content_formgroup do
    voo.edit_structure = %i[
      wikirate_title
      report_type
      year
      wikirate_topic
      description
    ]
  end
end