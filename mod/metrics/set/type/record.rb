def value year
  Answer.where(record_id: id, year: year.to_i).pluck(:value).first
end

def answer year
  Answer.where(record_id: id, year: year.to_i).first
end

def answers_by_year
  @aby ||=
    Answer.where(record_id: id).each_with_object({}) do |a, h|
      h[a.year] = a
    end
end