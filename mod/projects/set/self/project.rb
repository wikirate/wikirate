format :html do
  view :core, template: :haml
end

format :csv do
  def title_row
    CSV.generate_line ["PROJECT", "METRICS", "COMPANIES", "ANSWERS",
                       "USERS", "COMMUNITY-ASSESSED", "DESIGNER-ASSESSED", "CREATED AT"]
  end

  view :core do
    total = [0, 0, 0]
    Card.search(type_id: card.id).map do |pc|
      cnts = [pc.num_metrics, pc.num_companies, pc.num_answers, pc.num_users]
      3.times do |i|
        total[i] += cnts[i]
      end
      CSV.generate_line([pc.name] + cnts + pc.num_policies + [pc.created_at])
    end.unshift(title_row).push(CSV.generate_line(["TOTAL"] + total)).join
  end
end
