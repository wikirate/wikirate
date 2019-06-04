RSpec.shared_context "company ids" do
  let(:apple_id) { Card.fetch_id "Apple Inc" }
  let(:spectre_id) { Card.fetch_id "SPECTRE" }
  let(:death_star_id) { Card.fetch_id "Death Star" }
  let(:samsung_id) { Card.fetch_id "Samsung" }

  let(:sony) { Card.fetch_id "Sony Corporation" }
  let(:samsung) { Card.fetch_id "Samsung" }
  let(:death_star) { Card.fetch_id "Death Star" }
  let(:apple) { Card.fetch_id "Apple Inc" }
  let(:slate_rock) { Card.fetch_id "Slate Rock and Gravel Company" }
  let(:los_pollos) { Card.fetch_id "Los Pollos Hermanos" }
  let(:spectre) { Card.fetch_id "SPECTRE" }
end
