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
        article = Card.fetch("#{company.name}+#{topic.name}+article")
        Card::Auth.as_bot do
          article.update_attributes!(:content=>"change about")
        end
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
          about.update_attributes!(:content=>"change about")
        end
      end
      it { is_expected.to eq(@contr_count+1) }
    end
    
    context "when article edited" do
      before do
        article = Card.fetch("#{company.name}+#{topic.name}+article")
        Card::Auth.as_bot do
          article.update_attributes!(:content=>"change about")
        end
      end
      it { is_expected.to eq(@contr_count+1) }
    end
    
  end
end