event :delayed_job_test, after: :subsequent, on: :save do
  Auth.as_bot do
    test_card = Card['*delayed job test'] ||
                  Card.create!(name: '*delayed job test',
                               type_id: Card::PointerID)
    test_card.add_item! "%s: %s" % [Time.zone.now, name]
  end
end
