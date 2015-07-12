format :html do
  view :content do |args|
    key = "view_content_card_#{card.key}_args_#{Card::Cache.obj_to_key args}"
    Card::Cache[Card::Set::Right::YinyangDragItem].fetch key do
      super(args)
    end
  end
end