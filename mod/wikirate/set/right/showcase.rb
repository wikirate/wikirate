format :html do
  view :open do |args|
    if Auth.current_id == card.left.id || card.type_code == :wikirate_company
      args.merge! :slot_class=>'editable'
    end
    super(args)
  end


  # view :core do |args|
  # [CampaignID, MetricID, ClaimID, SourceID, WikirateArticleID].map do |type_id|
  #     if (search_card = card.fetch(:trait=>type_id, :new=>{:type_id=>PointerID}))
  #       nest(search_card, :slot_class=>('hidden' if search_card.item_cards.empty?), :view=>:yinyang_list)
  #     end
  #   end
  # end
end