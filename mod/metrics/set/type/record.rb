def value year
  Answer.where(record_id: id, year: year.to_i).pluck(:value).first
end
