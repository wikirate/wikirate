describe Card::Set::All::Contributions do
  let(:company) { Card["Apple"] }
  let(:topic) { Card["Natural Resource Use"] }

  describe 'contribution count for company' do
    subject { company.contribution_count.to_i }
    before do
      company.update_contribution_count
      @contr_count = company.contribution_count.to_i
    end
    
    context "when claim added" do
      before do  
        create_claim "contributions claim", '+company'=>{:content=>"[[#{company.name}]"}
      end
      it { is_expected.to eq(@contr_count+1) }
    end
    
    context "when source added" do
      before do  
        create_page "http://www.google.com/?q=source", '+company'=>{:content=>"[[#{company.name}]]"}
      end
      it { is_expected.to eq(@contr_count+1) }
    end
        
    context "when +about edited" do
      before do
        about = Card.fetch("#{company.name}+about")
        Card::Auth.as_bot do
          about.update_attributes!(:content=>"change about")
        end
      end
      it { is_expected.to eq(@contr_count+1) }
    end
    
    context "when article edited" do
      before do
        @analysis = Card["#{company.name}+#{topic.name}"]
        @analysis.update_contribution_count
        @direct_cc = @analysis.direct_contribution_count.to_i
        company.update_contribution_count
        @contr_count = company.contribution_count.to_i
        
        article = Card.fetch("#{@analysis.name}+article")
        Card::Auth.as_bot do
          article.update_attributes!(:content=>"change about")
        end
      end
      it "increases analysis' direct contribution count" do
        expect(@analysis.direct_contribution_count.to_i).to eq (@direct_cc+1)
      end
      it { is_expected.to eq(@contr_count+1) }
    end
    
    context "when voted on claim" do
      before do
        @claim = Card.search(:type=>'claim',:right_plus=>["company",:link_to=>company.name]).last
        @claim.update_contribution_count
        @direct_cc = @claim.direct_contribution_count.to_i
        company.update_contribution_count
        @contr_count = company.contribution_count.to_i
        Card::Auth.as_bot do
          vote = @claim.vote_count_card
          vote.vote_up
          vote.save!
        end
      end
      it "increases claim's contribution count" do
        expect(@claim.contribution_count.to_i).to eq (@direct_cc+1)
      end
      it { is_expected.to eq(@contr_count+1) }
    end
    
    context "when voted on source" do
      before do
        @source = Card.search(:type=>'page',:right_plus=>["company",:link_to=>company.name]).last
        @source.update_contribution_count
        @direct_cc = @source.direct_contribution_count.to_i
        company.update_contribution_count
        @contr_count = company.contribution_count.to_i
        Card::Auth.as_bot do
          vote = @source.vote_count_card
          vote.vote_up
          vote.save!
        end
      end
      it "increases source's contribution count" do
        expect(@source.contribution_count.to_i).to eq (@direct_cc+1)
      end
      it { is_expected.to eq(@contr_count+1) }
    end
  end
  
  describe 'contribution count for topic' do
    subject {topic.contribution_count.to_i }
    before do
      topic.update_contribution_count
      @contr_count = topic.contribution_count.to_i
    end
    
    context "when claim added" do
      before do
        create_claim "contributions claim", '+topic'=>{:content=>"[[#{topic.name}]]"}
      end
      it { is_expected.to eq(@contr_count+1) }
    end
    
    context "when source added" do
      before do  
        create_page "http://www.google.com/?q=source", '+topic'=>{:content=>"[[#{topic.name}]]"}
      end
      it { is_expected.to eq(@contr_count+1) }
    end
    
    
    context "when +about edited" do
      before do
        about = Card.fetch("#{topic.name}+about")
        Card::Auth.as_bot do
          about.left.save!
          about.left.update_contribution_count
          @contr_count = about.left.contribution_count.to_i
          about.update_attributes!(:content=>"change about")
        end
      end
      it { is_expected.to eq(@contr_count+1) }
    end
    
    context "when article edited" do
      before do
        @analysis = Card["#{company.name}+#{topic.name}"]
        @analysis.update_contribution_count
        @direct_cc = @analysis.direct_contribution_count.to_i
        topic.update_contribution_count
        @contr_count = topic.contribution_count.to_i
        
        article = Card.fetch("#{@analysis.name}+article")
        Card::Auth.as_bot do
          article.update_attributes!(:content=>"change about")
        end
      end
      it "increases analysis' direct contribution count" do
        expect(@analysis.direct_contribution_count.to_i).to eq (@direct_cc+1)
      end
      it { is_expected.to eq(@contr_count+1) }
    end
    
  end
end