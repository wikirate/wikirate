describe Card::Set::Right::NovoteeSearch do
  describe "#get_result_from_session" do
    subject do
      Card.fetch(company, :metric, :novotee_search).format
          .list_with_no_session_votes
    end

    let(:company) { Card["Death Star"] }
    let(:metrics) do
      [Card["Jedi+disturbances in the Force"],
       Card["Fred+dinosaurlabor"]]
    end

    def vote_down metric
      Card::Auth.as_bot do
        vcc = metric.vote_count_card
        vcc.vote_down
        vcc.save!
      end
    end

    it "returns correct results without being voted" do
      with_user "Anonymous" do
        vote_down metrics[1]
        is_expected.to include(metrics[0].name)
        is_expected.not_to include(metrics[1].name)
      end
    end
  end
end
