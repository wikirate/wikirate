format :html do
  view :open do
    if (l = card.left) &&
       (Auth.current_id == l.id || l.type_code == :wikirate_company)
      class_up "card-slot", "editable"
    end
    super()
  end

  # view :core do |args|
  # [CampaignID, MetricID, ClaimID, SourceID, OverviewID].map do |type_id|
  #     if (search_card = card.fetch(:trait=>type_id, :new=>{:type_id=>PointerID}))
  #       nest(search_card, :slot_class=>('hidden' if search_card.item_cards.empty?), :view=>:yinyang_list)
  #     end
  #   end
  # end
end
