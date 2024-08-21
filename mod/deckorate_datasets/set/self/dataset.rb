include_set Abstract::DatasetSearch
include_set Abstract::FeaturedBoxes
include_set Abstract::FluidLayout

format :html do
  view :page, template: :haml, wrap: :slot
end

format :csv do
  view :header do
    [["DATA SET", "METRICS", "COMPANIES", "ANSWERS",
      "USERS", "COMMUNITY-ASSESSED", "DESIGNER-ASSESSED", "CREATED AT"]]
  end

  view :body do
    total = [0, 0, 0, 0, 0, 0]
    Card.search(type_id: card.id).map do |pc|
      ([pc.name, pc.num_metrics, pc.num_companies, pc.num_answers, pc.num_users] +
        pc.num_policies + [pc.created_at]).tap do |counts|
        6.times { |i| total[i] += counts[i + 1] }
      end
    end.push(["TOTAL"] + total)
  end
end
