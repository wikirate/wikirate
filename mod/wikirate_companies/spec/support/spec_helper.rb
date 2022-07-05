RSpec.shared_context "with company ids" do
  let(:apple_id) { "Apple Inc".card_id }
  let(:spectre_id) { "SPECTRE".card_id }
  let(:death_star_id) { "Death Star".card_id }
  let(:samsung_id) { "Samsung".card_id }

  let(:sony) { "Sony Corporation".card_id }
  let(:samsung) { "Samsung".card_id }
  let(:death_star) { "Death Star".card_id }
  let(:apple) { "Apple Inc".card_id }
  let(:slate_rock) { "Slate Rock and Gravel Company".card_id }
  let(:los_pollos) { "Los Pollos Hermanos".card_id }
  let(:spectre) { "SPECTRE".card_id }
end

RSpec.configure do |config|
  config.before do
    # TODO: do not remove the following before resolving the testing issue in
    # mod/wikirate_companies/spec/set/type/wikirate_company_spec.rb
    # puts "spectracular: #{Card["Jedi+disturbances in the Force+SPECTRE+2000"]&.name}"
  end
end
