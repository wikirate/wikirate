=begin
shared_examples_for 'contributions' do |subject_type|
  company_name = "Death Star"
  topic_name   = "Force"
  subject { @subject.contribution_count.to_i }
  before do

    @subject = case subject_type
      when :company then  Card[company_name]
      when :topic   then  Card[topic_name]
      end
    @subject.update_contribution_count
    @initial_count = @subject.contribution_count.to_i
  end

  context "when note added" do
    before do
      note = create_claim("That's no moon.", "+#{subject_type}"=>{:content=>"[[#{@subject.name}]"})
    end
    it "increases by 2" do
      is_expected.to eq(@initial_count+2)
    end
  end

  context "when source added" do
    before do
      @initial_count = @subject.contribution_count.to_i
      @page = create_page "http://www.google.com/?q=source",
        "+#{subject_type}"=>{:content=>"[[#{@subject.name}]]"}
    end
    it "increases by 2" do
      is_expected.to eq(@initial_count+2)
    end
  end

  context "when overview edited" do
    before do
      @analysis = Card["#{company_name}+#{topic_name}"]
      @analysis.update_contribution_count
      @direct_cc = @analysis.direct_contribution_count.to_i
      @subject.update_contribution_count
      @initial_count = @subject.contribution_count.to_i
      article = @analysis.fetch :trait=>:overview, :new=>{}
      Card::Auth.as_bot do
        article.update_attributes!(:content=>"change about")
      end
    end
    it "increases analysis' direct contribution count" do
      expect(@analysis.direct_contribution_count.to_i).to eq (@direct_cc+1)
    end
    it { is_expected.to eq(@initial_count+1) }
  end

  context "when voted on note" do
    before do
      @note = Card['Death Star uses dark side of the Force']
      @note.update_contribution_count
      @note_cc = @note.contribution_count.to_i

      @subject.update_contribution_count
      @initial_count = @subject.contribution_count.to_i
      Card::Auth.current_id = Card['Joe Admin'].id
      vote = @note.vote_count_card
      vote.vote_up
      vote.save!
    end
    it "increases note's contribution count" do
      expect(@note.contribution_count.to_i).to eq (@note_cc+1)
    end
    it { is_expected.to eq(@initial_count+1) }
  end

  context "when voted on source" do
    before do
      @source = Card['Death Star uses dark side of the Force+source'].item_cards.first
      @source.update_contribution_count
      @source_cc = @source.contribution_count.to_i

      @subject.update_contribution_count
      @initial_count = @subject.contribution_count.to_i
      Card::Auth.current_id = Card['Joe Admin'].id
      vote = @source.vote_count_card
      vote.vote_up
      vote.save!
    end
    it "increases source's contribution count" do
      expect(@source.contribution_count.to_i).to eq (@source_cc+1)
    end
    it { is_expected.to eq(@initial_count+1) }
  end
end

describe Card::Set::All::Contributions do
  describe 'contribution count for company' do
    it_behaves_like 'contributions', :company

     context "when +image created" do
      before do
        @company = get_a_sample_company
        @initial_count = @company.contribution_count.to_i
        Card::Auth.as_bot do
          Card.create! name: "#{@company.name}+image",
                       type_code: 'image',
                       image: File.new("#{Rails.root}/mod/wikirate/" \
                                        'spec/set/all/DeathStar.jpg')
        end
      end
      it "adds one to contribution counter" do
        expect(@company.contribution_count.to_i).to eq(@initial_count+1)
      end
    end
  end

  describe 'contribution count for topic' do
    it_behaves_like 'contributions', :topic
    context "when +image created" do
      before do
        @topic = get_a_sample_topic
        @initial_count = @topic.contribution_count.to_i

        Card::Auth.as_bot do
          Card.create! name: "#{@topic.name}+image",
                       type_code: 'image',
                       image: File.new("#{Rails.root}/mod/wikirate/" \
                                        'spec/set/all/DeathStar.jpg')
        end
      end
      it "adds one to contribution counter" do
        expect(@topic.contribution_count.to_i).to eq(@initial_count+1)
      end
    end

    # +about gets included via topic+*right sidebar+*type plus right+*structure
    # and hence is not recognized as a referenced field
    # context "when +about edited" do
    #   before do
    #     @topic = get_a_sample_topic
    #     @initial_count = @topic.contribution_count.to_i
    #
    #     about = Card.fetch("#{@topic.name}+about")
    #     Card::Auth.as_bot do
    #       about.update_attributes!(:content=>"change about")
    #     end
    #   end
    #   it "adds one to contribution counter" do
    #     expect(@topic.contribution_count.to_i).to eq(@initial_count+1)
    #   end
    # end

  end
end
=end
