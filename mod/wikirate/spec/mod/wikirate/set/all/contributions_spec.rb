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
  
  context "when claim added" do
    before do
      claim = create_claim("That's no moon.", "+#{subject_type}"=>{:content=>"[[#{@subject.name}]"})
    end
    it "increases by 2" do
      is_expected.to eq(@initial_count+2)
    end
  end

  context "when source added" do
    before do
      @initial_count = @subject.contribution_count.to_i
      create_page "http://www.google.com/?q=source", "+#{subject_type}"=>{:content=>"[[#{@subject.name}]]"}
    end
    it "increases by 2" do
      is_expected.to eq(@initial_count+2)
    end
  end

  context "when +about edited" do
    before do
      about = Card.fetch("#{@subject.name}+about")
      Card::Auth.as_bot do
        about.update_attributes!(:content=>"change about")
      end
    end
    it { is_expected.to eq(@initial_count+1) }
  end

  context "when article edited" do
    before do
      @analysis = Card["#{company_name}+#{topic_name}"]
      @analysis.update_contribution_count
      @direct_cc = @analysis.direct_contribution_count.to_i
      @subject.update_contribution_count
      @initial_count = @subject.contribution_count.to_i

      article = Card.fetch("#{@analysis.name}+article")
      Card::Auth.as_bot do
        article.update_attributes!(:content=>"change about")
      end
    end
    it "increases analysis' direct contribution count" do
      expect(@analysis.direct_contribution_count.to_i).to eq (@direct_cc+1)
    end
    it { is_expected.to eq(@initial_count+1) }
  end

  context "when voted on claim" do
    before do
      @claim = Card['Death Star uses dark side of the Force']
      @claim.update_contribution_count
      @claim_cc = @claim.contribution_count.to_i
      
      @subject.update_contribution_count
      @initial_count = @subject.contribution_count.to_i
      Card::Auth.current_id = Card['Joe Admin'].id
      vote = @claim.vote_count_card
      vote.vote_up
      vote.save!
    end
    it "increases claim's contribution count" do
      expect(@claim.contribution_count.to_i).to eq (@claim_cc+1)
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
  end
  
  describe 'contribution count for topic' do
    it_behaves_like 'contributions', :topic
  end
end
