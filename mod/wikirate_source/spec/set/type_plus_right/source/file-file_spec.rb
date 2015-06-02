describe Card::Set::TypePlusRight::Source::File::File do
  describe "while editing a file source" do
    before do
      login_as 'joe_user' 
    end
    it "rejects updating a file source" do
      file1 = File.new "#{Rails.root}/mod/wikirate_source/spec/set/type_plus_right/source/file1.txt"
      file2 = File.new "#{Rails.root}/mod/wikirate_source/spec/set/type_plus_right/source/file2.txt"
      file1_uploaded = ActionDispatch::Http::UploadedFile.new(:tempfile => file1, :filename => File.basename(file1))
      file2_uploaded = ActionDispatch::Http::UploadedFile.new(:tempfile => file2, :filename => File.basename(file2))
      source = Card.create! :type_id=>Card::SourceID,:subcards=>{'+File'=>{ :attach=>file1_uploaded,:content=>"CHOSEN",:type_id=>Card::FileID}}

      source_file = Card["#{source.name}+File"]
      source_file.attach = file2_uploaded

      expect(source_file.save).to be false
      expect(source_file.errors).to have_key(:file)
      expect(source_file.errors[:file]).to include("is not allowed to be changed.")

    end
  end
end