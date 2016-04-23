# encoding: UTF-8

describe Card::Set::TypePlusRight::WikirateTopic::Claim do
  it 'updates cached count' do
    climate_change_notes = Card.fetch 'Climate Change', :claim
    expect(climate_change_notes.cached_count).to eq 0
    note = get_a_sample_note
    topic_list = note.fetch trait: :wikirate_topic, new: {}
    topic_list.add_item! 'Climate Change'
    expect(climate_change_notes.cached_count).to eq 1
  end
end