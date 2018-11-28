module SourceHelper
  def create_source source, subcards: {}, codename: nil
    Card::Auth.as_bot do
      Card.create! type_id: Card::SourceID,
                   codename: codename,
                   subcards: source_subcard_args(source, subcards),
                   skip: :requirements
    end
  end

  def new_source source, subcards: {}
    Card.new type_id: Card::SourceID,
             subcards: source_subcard_args(source, subcards)
  end

  def source_subcard_args source, subcards={}
    source ||= "http://www.google.com/?q=wikirate"
    subcards.reverse_merge! "+File"        => source_file_args(source) # ,
                            # "+Title"       => "Sample Source Title",
                            # "+Year"        => "1999",
                            # "+Company"     => "Death Star",
                            # "+Report Type" => "Creature Report"
  end

  def source_file_args source
    key = source.is_a?(String) ? :remote_file_url : :file
    { type_id: Card::FileID, key => source }
  end
end
