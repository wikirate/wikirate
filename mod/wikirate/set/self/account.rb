def count
  Card::Act.select(:actor_id).distinct.count
end

def count_label
  "Contributors"
end
