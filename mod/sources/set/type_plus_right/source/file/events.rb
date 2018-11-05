event :download_source_file, before: :prepare_attachment, when: :web_file? do

end

def web_file
  card.content.present?
end