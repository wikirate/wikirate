# encoding: UTF-8

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::WikirateCompany::Source do
  let(:apple_sources) { Card.fetch "Apple Inc", :source }
  it "updates cached count" do
    source = sample_source
    company_list = source.fetch trait: :wikirate_company, new: {}
    company_list.drop_item! "Apple Inc"
    expect(apple_sources.cached_count).to eq 0
    company_list.add_item! "Apple Inc"
    expect(apple_sources.cached_count).to eq 1
  end

  it_behaves_like "cached count", 3 do
    let :card do
      Card["Death Star+source"]
    end
    let :add_one do
      source = Card.create!(
        type_id: Card::SourceID,
        subcards: { "+Link" => { content: "http://www.wikiwand.com/en/Apple" } }
      )
      Card.fetch(source, :wikirate_company, new:{}).add_item! "Death Star"
    end
  end
end
