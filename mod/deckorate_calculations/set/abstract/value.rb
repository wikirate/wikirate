event :schedule_calculation_update, :integrate, skip: :allowed do
  record_card.update_related_calculations
end
