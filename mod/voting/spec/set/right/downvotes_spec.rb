describe Card::Set::Right::Downvotes do
  before do
    @claim = create_claim "a claim"
    @dv_card = Card['joe user'].downvotes_card
  end
  
  describe '#add_item' do
    it 'decreases voting count' do
      Card::Auth.as_bot do
        vc = @claim.vote_count.to_i
        @dv_card.add_item @claim.name
        expect(@claim.vote_count.to_i).to eq vc-1
      end
    end
    
    it 'decreases voting count only once' do 
      Card::Auth.as_bot do
        vc = @claim.vote_count.to_i
        @dv_card.add_item @claim.name
        @dv_card.save!
        @dv_card.add_item @claim.name
        @dv_card.save!
        expect(@claim.vote_count.to_i).to eq vc-1
      end
    end
      
    it 'adds claim to downvotes pointer' do
      @dv_card.add_item @claim.name
      Card::Auth.as_bot do
        @dv_card.save!
      end
      expect(Card.fetch('joe user+*downvotes').content).to match "[[#{@claim.name}]]"
    end
  end
  
  describe '#drop_item' do
    before do
      Card::Auth.as_bot do
        @dv_card.add_item @claim.name
        @dv_card.save!
      end
    end
    it 'increases voting count' do
      Card::Auth.as_bot do
        vc = @claim.vote_count.to_i
        @dv_card.drop_item @claim.name
        @dv_card.save!
        expect(@claim.vote_count.to_i).to eq vc+1
      end
    end
    
    it 'increases voting count only once' do
      Card::Auth.as_bot do
        vc = @claim.vote_count.to_i
        @dv_card.drop_item @claim.name
        @dv_card.save!
        @dv_card.drop_item @claim.name
        @dv_card.save!
        expect(@claim.vote_count.to_i).to eq vc+1
      end
    end
    
    it 'removes claim from downvotes pointer' do
      Card::Auth.as_bot do
        @dv_card.drop_item @claim.name
        @dv_card.save!
      end
      expect(Card.fetch('joe user+*downvotes').content).not_to match "[[#{@claim.name}]]"
    end
  end
  
end