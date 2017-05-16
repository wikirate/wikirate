format :csv do
  def title_row
    CSV.generate_line ["PROJECT", "METRICS", "COMPANIES", "USERS", "ANSWERS", "DESIGNER/COMMUNITY-ASSESSED"]
  end

  view :core do
    Card.search(type_id: card.id).map do |pc|
      CSV.generate_line([pc.name, pc.num_metrics, pc.num_companies,
                        pc.num_users, pc.num_answers, pc.num_policies])
    end.unshift(title_row).join
  end
end
