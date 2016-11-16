include_set Abstract::Import

def metric_pointer_card
  subcard cardname.left_name.field(:metric)
end

def year_pointer_card
  subcard cardname.left_name.field(:year)
end

def metric
  metric_pointer_card.item_names.first
end

def year
  year_pointer_card.item_names.first
end

def source_url
  "#{Env[:protocol]}#{Env[:host]}/#{left.cardname.url_key}"
end

event :validate_import, :prepare_to_validate,
      on: :update,
      when: proc { Env.params["is_data_import"] == "true" } do
  check_card metric_pointer_card, "Metric", Card::MetricID
  check_card year_pointer_card, "Year", Card::YearID
end

# @return [Hash] args to create metric value card
def process_data metric_value_data
  mv_hash = super(metric_value_data)
  mv_hash.merge metric: metric,
                year: year,
                source: source_url
end

def redirect_target_after_import
  metric
end

def check_card card, name, id
  if !card || !(related_card = card.item_cards.first)
    errors.add :content, "Please give a #{name}."
  elsif related_card.type_id != id
    errors.add :content, "Invalid #{name}"
  end
end

format :html do
  def import_fields
    [:file_company, :value]
  end
end
