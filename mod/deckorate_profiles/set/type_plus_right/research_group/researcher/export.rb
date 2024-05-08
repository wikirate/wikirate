include_set Abstract::Export

# def ok_to_export?
#   Auth.always_ok? || as_wikirate_team? || Auth.as_id.in?(left.organizer_card.item_ids)
# end

format do
  def filter_and_sort_hash
    {}
  end
end

format :csv do
  view :titles do
    ["Researcher Name"] +
      CONTRIBUTION_CATEGORY_HEADER[1..-1].map { |action| "Answers #{action}" }
  end

  view :body do
    card.item_cards.map do |member|
      [member.name] + contribution_counts(member)
    end
  end
end

format :json do
  view :titled do
    render_molecule
  end

  def molecule
    super.tap do |atom|
      atom[:items] = card.item_cards.map { |member| counts_for_member member }
    end
  end

  def counts_for_member member
    { name: member.name }.tap do |hash|
      contribution_counts(member).each_with_index do |count, index|
        hash[CONTRIBUTION_CATEGORIES[index]] = count
      end
    end
  end
end
