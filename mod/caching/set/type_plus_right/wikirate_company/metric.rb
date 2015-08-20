include Card::CachedCount

expired_cached_count_cards :set=>Card::Set::LtypeRtype::Metric::WikirateCompany,
                      :on=>[:create,:delete] do |changed_card|
  if (metric_count_card = changed_card.fetch(:trait=>:metric))
    metric_count_card
  end
end