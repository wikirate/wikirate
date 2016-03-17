include Card::Set::Abstract::Import

def metric_pointer_card
  subcards[cardname.left + "+#{Card[:metric].name}"]
end

def metric_year_card
  subcard(cardname.left + "+#{Card[:year].name}")
end

def metric_content
  metric_pointer_card.item_names.first
end

def metric_year_content
  metric_year_card.item_names.first
end

event :validate_import, :prepare_to_validate,
      on: :update,
      when: proc { Env.params['is_metric_import_update'] == 'true' } do
  check_card metric_pointer_card, 'Metric', Card::MetricID
  check_card metric_year_card, 'Year', Card::YearID
end

def import_csv_information
  corrected_company_hash = clean_corrected_company_hash
  return unless (metric_values = Env.params[:metric_values]) &&
                metric_values.is_a?(Hash)
  metric_values.each do |company, value|
    metric_value_card =
      create_metric_value_from_params company, corrected_company_hash, value
    next if metric_value_card.errors.empty?
    metric_value_card.errors.each do |key, error_value|
      errors.add key, error_value
    end
  end
  handle_redirect metric_pointer_card
end

def create_metric_value_from_params company, company_hash, value
  final_company_name = get_final_company_name company, company_hash
  metric_value_card_name = "#{metric_content}+#{final_company_name}+"\
                           "#{metric_year_content}"
  source_url = "#{Env[:protocol]}#{Env[:host]}/#{left.cardname.url_key}"
  subcard = metric_value_subcards metric_content, final_company_name,
                                  metric_year_content,
                                  value[0], source_url
  create_or_update_mv_card metric_value_card_name, subcard
end

def check_card card, name, id
  if !card || !(related_card = card.item_cards.first)
    errors.add :content, "Please give a #{name}."
  elsif related_card.type_id != id
    errors.add :content, "Invalid #{name}"
  end
end

format :html do
  include Card::Set::Abstract::Import::HtmlFormat
end
