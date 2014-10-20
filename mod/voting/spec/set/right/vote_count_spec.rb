describe Card::Set::Right::VoteCount do 
  before do
    @claim = create_claim "another voting claim"
    @card = @claim.vote_count_card
  end
  
  it 'default vote count is 0' do
    expect(@claim.vote_count.to_i).to eq 0
  end
  
  describe "#vote_status" do
    subject { @card.vote_status}
    context "when not voted by user" do
      it { is_expected.to eq("?")}
    end 
    context "when upvoted by user" do
      before do
        Card::Auth.as_bot { @card.vote_up }
      end
      it { is_expected.to eq("+")}
    end
    context "when downvoted by user" do
      before do
        Card::Auth.as_bot { @card.vote_down }  
      end
      it { is_expected.to eq("-")}
    end
    context "when not signed in" do
      subject do 
        Card::Auth.current_id = Card::AnonymousID
        @card.vote_status
      end
      it { is_expected.to eq("#")}
    end
  end
  
  describe "#vote_up" do
    context "when voted down" do
      before do
        Card::Auth.as_bot do
          @card.vote_down
          @card.save!
          @uvc = @claim.upvote_count.to_i
          @dvc = @claim.downvote_count.to_i
          @vc = @claim.vote_count.to_i
          @card = @claim.vote_count_card
          @card.vote_up
          @card.save!
        end
      end
      it "decreases downvote count" do
        Card::Auth.as_bot do
          expect(@claim.downvote_count.to_i).to eq @dvc-1
        end
      end
      it "doesn't change upvote count" do
        Card::Auth.as_bot do
          expect(@claim.upvote_count.to_i).to eq @uvc
        end
      end
      it "increases vote count" do
        expect(@claim.vote_count.to_i).to eq @vc+1
      end
    end
    context "when not voted" do
      before do
        Card::Auth.as_bot do
          @uvc = @claim.upvote_count.to_i
          @vc = @claim.vote_count.to_i
          @card.vote_up
          @card.save!
        end
      end
      it "increases upvote count" do
        Card::Auth.as_bot do
          expect(@claim.upvote_count.to_i).to eq @uvc+1
        end
      end
      it "increases vote count" do
        expect(@claim.vote_count.to_i).to eq @vc+1
      end
      it "increases upvote count only once" do
        Card::Auth.as_bot do
          card = @claim.vote_count_card
          card.vote_up
          card.save!
        end
        expect(@claim.upvote_count.to_i).to eq @uvc+1
      end
    end
  end
  
  describe "#vote_down" do
    context "when voted up" do
      before do
        Card::Auth.as_bot do
          @card.vote_up
          @card.save!
          @uvc = @claim.upvote_count.to_i
          @dvc = @claim.downvote_count.to_i
          @vc = @claim.vote_count.to_i
          @card = @claim.vote_count_card
          @card.vote_down
          @card.save!
        end
      end
      it "decreases upvote count" do
        Card::Auth.as_bot do
          expect(@claim.upvote_count.to_i).to eq @uvc-1
        end
      end
      it "doesn't change downvote count" do
        Card::Auth.as_bot do
          expect(@claim.downvote_count.to_i).to eq @dvc
        end
      end
      it "decreases vote count" do
        expect(@claim.vote_count.to_i).to eq @vc-1
      end
    end
    context "when not voted" do
      before do
        Card::Auth.as_bot do
          @dvc = @claim.upvote_count.to_i
          @vc = @claim.vote_count.to_i
          @card.vote_down
          @card.save!
        end
      end
      it "increases downvote count" do
        Card::Auth.as_bot do
          expect(@claim.downvote_count.to_i).to eq @dvc+1
        end
      end
      it "decreases vote count" do
        expect(@claim.vote_count.to_i).to eq @vc-1
      end
      it "increases downvote count only once" do
        Card::Auth.as_bot do
          card = @claim.vote_count_card
          card.vote_down
          card.save!
        end
        expect(@claim.downvote_count.to_i).to eq @dvc+1
      end
    end
  end
  
  describe "core view" do
    before do
      Card::Auth.as_bot  do
        @card.save!
      end
    end
    let(:core_view)  { @card.format.render_core }
    it "has 'vote up' button" do
      assert_view_select core_view, 'button i[class~=fa-angle-up]'
      assert_view_select core_view, 'button[disabled="disabled"] i[class~=fa-angle-up]', :count=>0
    end
    it "has 'vote down' button" do
      assert_view_select core_view, 'button i[class~=fa-angle-down]'
      assert_view_select core_view, 'button[disabled="disabled"] i[class~=fa-angle-down]', :count=>0
    end
    context "when voted up" do
      before do
        Card::Auth.as_bot do
          @card.vote_up
          @card.save
        end
      end
      it "has disabled 'vote up' button" do
        assert_view_select core_view, 'button[disabled="disabled"] i[class~=fa-angle-up]'
      end
    end
    context "when voted down" do
      before do
        Card::Auth.as_bot do
          @card.vote_down
          @card.save
        end
      end
      it "has disabled 'vote down' button" do
        assert_view_select core_view, 'button[disabled="disabled"] i[class~=fa-angle-down]'
      end
    end
  end
  
  # describe "#add_upvote" do
  #   it "increases upvote count" do
  #     uvc = @card.upvote_count.to_i
  #     @card.add_upvote
  #     expect(@card.upvote_count.to_i).to eq uvc+1
  #   end
  #   it "increases vote count" do
  #     vc = @card.vote_count.to_i
  #     @card.add_upvote
  #     expect(@card.vote_count.to_i).to eq vc+1
  #   end
  # end
  # describe "#delete_upvote" do
  #   it "decreases upvote count" do
  #     uvc = @card.upvote_count.to_i
  #     @card.delete_upvote
  #     expect(@card.upvote_count.to_i).to eq uvc-1
  #   end
  #   it "decreases vote count" do
  #     vc = @card.vote_count.to_i
  #     @card.delete_upvote
  #     expect(@card.vote_count.to_i).to eq vc-1
  #   end
  # end
  #
  # describe "#add_downvote" do
  #   it "increases downvote count" do
  #     dvc = @card.downvote_count.to_i
  #     @card.add_downvote
  #     expect(@card.downvote_count.to_i).to eq dvc+1
  #   end
  #   it "decreases vote count" do
  #     vc = @card.vote_count.to_i
  #     @card.add_downvote
  #     expect(@card.vote_count.to_i).to eq vc-1
  #   end
  # end
  # describe "#delete_downvote" do
  #   it "decreases downvote count" do
  #     dvc = @card.downvote_count.to_i
  #     @card.delete_downvote
  #     expect(@card.downvote_count.to_i).to eq dvc-1
  #   end
  #   it "increases vote count" do
  #     vc = @card.vote_count.to_i
  #     @card.delete_downvote
  #     expect(@card.vote_count.to_i).to eq vc+1
  #   end
  # end 
end