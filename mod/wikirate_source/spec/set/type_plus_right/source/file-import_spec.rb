describe Card::Set::TypePlusRight::Source::File::Import do
  before do
    login_as 'joe_user' 
    test_csv = File.new "#{Rails.root}/mod/wikirate_source/spec/set/type_plus_right/source/import_test.csv"
    file_uploaded = ActionDispatch::Http::UploadedFile.new(:tempfile => test_csv, :filename => File.basename(test_csv))
    
    @source = Card.create! :type_id=>Card::SourceID,:subcards=>{'+File'=>{ :attach=>file_uploaded,:content=>"CHOSEN",:type_id=>Card::FileID}}
  end
  describe "while adding metric value" do
    it "shows errors while params do not fit" do 

      # Card::Env.params["is_metric_import_update"] = 'true'
      # source_file = @source.fetch :trait=>:file
      # source_file.update_attributes :subcards=>
      # {
      #   "#{@source.name}+#{Card[:metric].name}"=>{:content=>'[[Clean Clothes Campaign+Strategy]]',:type_id=>Card::PointerID}}
      
      # expect(source_file.errors).to have_key(:content)
      # expect(source_file.errors[:content]).to include("Please give a year.")
      
      # source_file.update_attributes :subcards=>{"#{@source.name}+#{Card[:year].name}"=>'[[2015]]'}
      
      # expect(source_file.errors).to have_key(:content)
      # expect(source_file.errors[:content]).to include("Please give a metric.")

      # source_file.update_attributes :subcards=>{"#{@source.name}+#{Card[:year].name}"=>'[[yyyy]]'}
      
      # expect(source_file.errors).to have_key(:content)
      # expect(source_file.errors[:content]).to include("Invalid Year")

      # source_file.update_attributes :subcards=>{"#{@source.name}+#{Card[:metric].name}"=>'[[yyyy]]'}
      
      # expect(source_file.errors).to have_key(:content)
      # expect(source_file.errors[:content]).to include("Invalid metric")

    end
  end
  describe "while rendering import view" do
    
    it "shows field correctly" do
      

      source_file_card = @source.fetch :trait=>:file
      html = source_file_card.format.render_import      

      expect(html).to have_tag("div", :with=>{:card_name=>"#{@source.name}+metric"}) do
        with_tag "input", :with=>{:class=>"card-content form-control",:id=>"card_subcards_#{@source.name}_metric_content"}
      end
      expect(html).to have_tag("div", :with=>{:card_name=>"#{@source.name}+Year"}) do
        with_tag "input", :with=>{:class=>"card-content form-control",:id=>"card_subcards_#{@source.name}_Year_content"}
      end
      expect(html).to have_tag("input", :with=>{:id=>"is_metric_import_update",:value=>"true",:type=>"hidden"}) 
      expect(html).to have_tag("table", :with=>{:class=>"import_table"}) do
        with_tag "tr" do 
          with_tag "input", :with=>{:disabled=>"disabled",:type=>"checkbox",:value=>"43",:id=>"metric_values__"} 
          with_tag "td",:text=>"Always code as if the guy who ends up maintaining your code will be a violent psychopath who knows where you live"
          with_tag "td",:text=>"none"
        end

        with_tag "tr" do 
          with_tag "input", :with=>{:checked=>"checked",:type=>"checkbox",:value=>"9",:id=>"metric_values_Amazon_"} 
          with_tag "td",:text=>"Amazon.com"
          with_tag "td",:text=>"Amazon"
          with_tag "td",:text=>"partial"
        end

        with_tag "tr" do 
          with_tag "input", :with=>{:checked=>"checked",:type=>"checkbox",:value=>"62",:id=>"metric_values_Apple_"} 
          with_tag "td",:text=>"Apple"
          with_tag "td",:text=>"exact"
        end
        with_tag "tr" do 
          with_tag "input", :with=>{:checked=>"checked",:type=>"checkbox",:value=>"33",:id=>"metric_values_Sony_Corporation_"} 
          with_tag "td",:text=>"Sony Corporation"
          with_tag "td",:text=>"Sony"
          with_tag "td",:text=>"partial"
        end

      end

    end
  end
end