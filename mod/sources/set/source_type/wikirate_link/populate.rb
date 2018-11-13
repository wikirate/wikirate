
def populate_website?
  !subfield(:wikirate_website).present? && subfield(:wikirate_link).present? &&
    errors.empty?
end
