module SourceHelper
  def create_source source="http://www.google.com/?q=wikirate",
                    subcards: {}, import: false
    subcards.reverse_merge! "+File" => source_file_args(source)
    Card::Auth.as_bot do
      Card.create! type_id: Card::SourceID, subcards: subcards, import: import
    end
  end

  def source_file_args source
    key = source.is_a?(String) ? :remote_file_url : :file
    { type_id: Card::FileID, key => source }
  end
end
