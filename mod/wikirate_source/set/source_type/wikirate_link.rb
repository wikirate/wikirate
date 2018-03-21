card_accessor :file, type: :file
card_accessor :wikirate_link, type: :phrase
card_accessor :wikirate_website, type: :pointer

alias_method :link_card, :wikirate_link_card

format :html do
  view :original_link do
    original_link card.wikirate_link, text: voo.title
  end
end

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
  abort :failure if errors.present?
end

event :duplication_check, after: :validate_link, on: :create do
  return unless duplicates.any?
  duplicated_name = duplicates.first.name.left
  if sourcebox?
    remove_subfield(:wikirate_link)
    self.name = duplicated_name
    save_in_session_card save: true, duplicate: true
    abort :success
  else
    errors.add :link,
               "exists already. <a href='/#{duplicated_name}'>Visit the source.</a>"
    abort :failure
  end
end

event :process_link, after: :duplication_check, on: :create do
  link_card.director.catch_up_to_stage :validate
  return if link_card.errors.present?

  download_and_add_file || populate_title_and_description
end

def duplicates
  @duplicates ||= Self::Source.find_duplicates url
end

def sourcebox?
  Card::Env.params[:sourcebox] == "true"
end

format :json do
  def essentials
    super.merge source_url: card.url
  end
end
