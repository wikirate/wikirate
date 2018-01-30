event :validate_link, after: :check_source, on: :create do
  if !(link_card = subfield(:wikirate_link)) || link_card.content.empty?
    errors.add(:link, "does not exist.")
    abort :failure
  end
  link_card.content.strip!
  @url = link_card.content

  # used to be restricted to the sourcebox=true case
  # I don't see why we shouldn't do this always  -pk
  validate_url
end

def validate_url
  # url refers to a wikirate source card
  if url_card
    replace_with_url_card if valid_url_card?
  elsif !url? || wikirate_url?
    errors.add :source, "does not exist."
  end
end

def replace_with_url_card
  clear_subcards
  self.name = url_card.name
  abort :success
end

def valid_url_card?
  return true if url_card.type_code == :source
  false.tap { errors.add :source, "must be a valid URL or a WikiRate source" }
end

def url
  @url ||= (wikirate_link&.strip) || ""
end

def url?
  url.start_with?("http://", "https://")
end

def wikirate_url?
  return false unless Card::Env[:protocol] && Card::Env[:host]
  url.start_with? "#{Card::Env[:protocol]}#{Card::Env[:host]}"
end

def url_card
  @url_card ||=
    if wikirate_url?
      # try to convert the link to source card,
      # easier for users to add source in +source editor
      uri = URI.parse(URI.unescape(url))
      Card[uri.path]
    else
      Card[url]
    end
end
