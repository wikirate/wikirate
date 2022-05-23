require "net/https"
require "uri"

format do
  def rate_subject
    @wikirate_subject ||= Card.fetch_name(:wikirate_company)
  end

  def rate_subjects
    @wikirate_subjects ||= rate_subject.pluralize
  end
end

format :html do
  view :name_formgroup do
    # force showing help text
    voo.help ||= true
    super()
  end
end
