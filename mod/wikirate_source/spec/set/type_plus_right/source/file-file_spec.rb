describe Card::Set::TypePlusRight::Source::File::File do
  describe "while editing a file source" do
    before do
      login_as 'joe_user' 
    end
    it "rejects updating a file source" do
      # binding.pry
      file1_path = "#{Rails.root}/mod/wikirate_source/spec/set/type_plus_right/source/file1.txt"
      file2_path = "#{Rails.root}/mod/wikirate_source/spec/set/type_plus_right/source/file2.txt"
      source = Card.create! :type_id=>Card::SourceID,:subcards=>{'+File'=>{ :attach=>File.new(file1_path),:type_id=>Card::FileID}}

      source_file = Card["#{source.name}+File"]
      source_file.attach = File.new(file2_path)

      expect(source_file.save).to be false
      expect(link_card.errors).to have_key(:link)
      expect(link_card.errors[:link]).to include("is not allowed to be changed")

    end
  end
end