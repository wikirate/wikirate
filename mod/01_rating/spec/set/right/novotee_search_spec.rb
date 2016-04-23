describe Card::Set::Right::NovoteeSearch do
  describe '#get_result_from_session' do
    before do
      login_as 'joe_user'

      @metrics = [
        get_a_sample_metric,
        Card.create!(name: 'Hello+World', type_id: Card::MetricID),
        Card.create!(name: 'Hello+Boys',  type_id: Card::MetricID)
      ]

      @company = get_a_sample_company

      @metrics.each do |metric|
        subcard = {
          '+metric'   => { 'content' => metric.name },
          '+company'  => {
            'content' => "[[#{@company.name}]]", type_id: Card::PointerID
          },
          '+value' => { 'content' => "I'm fine, I'm just not happy.",
                        type_id: Card::PhraseID
                      },
          '+year' => { 'content' => '2015', type_id: Card::PointerID },
          '+source' => {
            'subcards' => {
              'new source' => {
                '+Link' => {
                  'content' => 'http://www.google.com/?q=everybodylies',
                  'type_id' => Card::PhraseID
                }
              }
            }
          }
        }
        Card.create! type_id: Card::MetricValueID, subcards: subcard
      end
    end

    it "returns correct results without being voted" do
      Card::Auth.current_id = Card["Anonymous"].id
      Card::Auth.as_bot do
        vcc = @metrics[2].vote_count_card
        vcc.vote_down
        vcc.save!
      end
      @metrics.each do |metric|
        cached_count =
          Card.new name: "#{metric.name}+#{@company.name}+*cached count"
        cached_count.format.render_core
      end

      metric_novotee_search_card =
        @company.fetch trait: [:metric, :novotee_search]
      search_result =
        metric_novotee_search_card.format.list_with_no_session_votes
      expect(search_result).to include(@metrics[0].name)
      expect(search_result).to include(@metrics[1].name)

    end
  end
end