include_set Set::TypePlusRight::Metric::AllValues

def self.related_all_values_card changed_card
  # don't trigger the update if the metric itself was deleted
  # not sure what happens during a delete request but probably
  # the fetch already returns nil
  (mc = changed_card.company_card) && !mc.trash && mc.all_metric_values_card
end

def self.related_all_values_card_was changed_card
  (mc = changed_card.company_card_before_name_change) &&
    mc.all_meetric_values_card
end

def self.related_all_values_card_ changed_card
  (mc = changed_card.company_card) && mc.all_metric_values_card
end
