RSpec.configure do |config|
  config.before do
    # TODO: do not remove the following before resolving the testing issue in
    # mod/deckorate_search/spec/set/type/wikirate_company_spec.rb
    # puts "spectracular: #{Card["Jedi+disturbances in the Force+SPECTRE+2000"]&.name}"
  end
end
