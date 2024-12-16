include_set Abstract::DatasetSearch
include_set Abstract::FeaturedBoxes
include_set Abstract::FluidLayout

format :html do
  view :page, template: :haml, wrap: :slot

  def edit_fields
    %i[description featured]
  end
end

format :csv do
  view :header do
    [["DATASET", "METRICS", "COMPANIES", "ANSWERS",
      # "USERS",
      "COMMUNITY-ASSESSED", "DESIGNER-ASSESSED", "CREATED AT"]]
  end

  view :body do
    [].tap do |rows|
      each_dataset do |dataset|
        rows << dataset_row(dataset)
      end
    end
  end

  def dataset_row dataset
    [
      dataset.name,
      dataset.num_metrics,
      dataset.num_companies,
      dataset.num_answers,
      # dataset.num_users
    ] + dataset.num_policies + [
      dataset.created_at
    ]
  end

  def each_dataset
    Card.where(type_id: card.id).find_each do |dataset_card|
      dataset_card.include_set_modules
      yield dataset_card
    end
  end
end
