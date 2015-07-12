include Card::CachedCount

expired_cached_count_cards :set=>Card::Set::LtypeRtype::Metric::WikirateCompany,
                      :on=>[:create,:delete] do

  if (metric_count_card = fetch(:trait=>:metric))
    metric_count_card.update_cached_count
  end
end