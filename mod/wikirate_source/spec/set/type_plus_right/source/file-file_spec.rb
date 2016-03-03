describe Card::Set::TypePlusRight::Source::File::File do
  describe "while editing a file source" do
    before do
      login_as 'joe_user'
    end
    it "rejects updating a file source" do
      file1 = File.new "#{Rails.root}/mod/wikirate_source/spec/set/type_plus_right/source/file1.txt"
      file2 = File.new "#{Rails.root}/mod/wikirate_source/spec/set/type_plus_right/source/file2.txt"

      source = create_source file: file1
      source_file = Card["#{source.name}+File"]
      source_file.update_attributes :file=>file2

      expect(source_file.errors).to have_key(:file)
      expect(source_file.errors[:file]).to include("is not allowed to be changed.")

    end
  end
end