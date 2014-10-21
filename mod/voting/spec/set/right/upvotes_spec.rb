describe Card::Set::Right::Upvotes do
  # before do
  #   @claim = create_claim "a claim"
  #   @uv_card = Card['joe user'].upvotes_card
  # end
  
  # describe '#add_item' do
  #   it 'increases voting count' do
  #     Card::Auth.as_bot do
  #       vc = @claim.vote_count.to_i
  #       @uv_card.add_item @claim.name
  #       expect(@claim.vote_count.to_i).to eq vc+1
  #     end
  #   end
  #
  #   it 'increases voting count only once' do
  #     Card::Auth.as_bot do
  #       vc = @claim.vote_count.to_i
  #       @uv_card.add_item @claim.name
  #       @uv_card.save!
  #       @uv_card.add_item @claim.name
  #       @uv_card.save!
  #       expect(@claim.vote_count.to_i).to eq vc+1
  #     end
  #   end
  #
  #   it 'adds claim to upvotes pointer' do
  #     @uv_card.add_item @claim.name
  #     Card::Auth.as_bot do
  #       @uv_card.save!
  #     end
  #     expect(Card.fetch('joe user+*upvotes').content).to match "[[#{@claim.name}]]"
  #   end
  # end
  #
  # describe '#drop_item' do
  #   before do
  #     Card::Auth.as_bot do
  #       @uv_card.add_item @claim.name
  #       @uv_card.save!
  #     end
  #   end
  #   it 'decreases voting count' do
  #     Card::Auth.as_bot do
  #       vc = @claim.vote_count.to_i
  #       @uv_card.drop_item @claim.name
  #       @uv_card.save!
  #       expect(@claim.vote_count.to_i).to eq vc-1
  #     end
  #   end
  #
  #   it 'decreases voting count only once' do
  #     Card::Auth.as_bot do
  #       vc = @claim.vote_count.to_i
  #       @uv_card.drop_item @claim.name
  #       @uv_card.save!
  #       @uv_card.drop_item @claim.name
  #       @uv_card.save!
  #       expect(@claim.vote_count.to_i).to eq vc-1
  #     end
  #   end
  #
  #   it 'removes claim from upvotes pointer' do
  #     Card::Auth.as_bot do
  #       @uv_card.drop_item @claim.name
  #       @uv_card.save!
  #     end
  #     expect(Card.fetch('joe user+*upvotes').content).not_to match "[[#{@claim.name}]]"
  #   end
  # end  
end
