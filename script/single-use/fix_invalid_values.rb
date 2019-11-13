require File.expand_path "../../../config/environment", __FILE__

Card::Auth.current_id = Card.fetch_id "Ethan McCutchen"

VALUE_IDS_WRONG = %w[
  Clean_Clothes_Campaign+Address+J_Thomson_Colour_Printers_Ltd+2016
  Clean_Clothes_Campaign+Address+Core_Image_Ltd+2016
  Clean_Clothes_Campaign+Address+Corporate_Media_Supplies+2016
  Clean_Clothes_Campaign+Address+CPI_Colour+2016
  Clean_Clothes_Campaign+Address+Tactical_Fulfilment_Solutions_Ltd+2016
]

NO_VALUE_NO_SOURCE = %w[
  Walk_Free_Foundation+MSA_Performance_Indicators+Princes_Group+2017
  Business_Human_Rights_Resource_Centre+Modern_Slavery_statement+Huntapac_Produce_Ltd+2017
  Poverty_Footprint+Women_in_Management_Positions+Empresa_de_Energia_de_Bogota+2017
  Global_Reporting_Initiative+Environmental_fines_G4_EN29a+Grupoéxito+2017
  Business_Human_Rights_Resource_Centre+MSA_Statement_Approval+Huntapac_Produce_Ltd+2017
  Business_Human_Rights_Resource_Centre+MSA_Statement_Approval+Mitsubishi_Corporation+2016
  WikiRate_SDG_Metric_design+SDG13_Climate_Action_Actions+ArcelorMittal+2014
  Global_Reporting_Initiative+Direct_greenhouse_gas_GHG_emissions_Scope_1_G4_EN15_a+Wilmar_International+2014
  Global_Reporting_Initiative+Female_injury_rate_G4_LA6_a+Wilmar_International+2014
  Global_Reporting_Initiative+Environmental_fines_G4_EN29_a+Nedbank_Group+2014
  Global_Reporting_Initiative+Total_Waste_to_Landfill_G4_EN23_a+Sanlam+2014
  Global_Reporting_Initiative+Sulfur_Oxide_SOx_emissions_G4_EN21_a+Akbank+2014
  Richard_Mills+Combined_Scope_1_and_2_Greenhouse_Gas_emissions+Mars+2015
  Richard_Mills+Combined_Scope_1_and_2_Greenhouse_Gas_emissions+Mars+2014
]

NONSTANDARD_UNKNOWNS = %w[
  Global_Reporting_Initiative+Volatile_Organic_Compounds_VOC_emissions_G4_EN21_a+Axis_Communications_AB+2014
  Global_Reporting_Initiative+Sulfur_Oxide_SOx_emissions_G4_EN21_a+Axis_Communications_AB+2016
  Global_Reporting_Initiative+Persistent_Organic_Pollutants_POP_G4_EN21_a+Axis_Communications_AB+2017
  Global_Reporting_Initiative+NOx_emissions_G4_EN21_a+Axis_Communications_AB+2017
  Global_Reporting_Initiative+Average_hours_of_training_male_G4_LA9_a+Astrapak+2016
  Global_Reporting_Initiative+Full_time_employees_G4_10_b+Axis_Communications_AB+2016
  Global_Reporting_Initiative+Part_time_employees_G4_10_b+Axis_Communications_AB+2016
  Global_Reporting_Initiative+Energy_intensity_G4_EN5_a+Covestro+2016
  Global_Reporting_Initiative+Energy_Consumption_Outside_the_Organization_G4_EN4+Covestro+2016
  Global_Reporting_Initiative+Fuel_consumption_from_renewable_sources_G4_EN3_b+General_Mills_Inc+2017
  Global_Reporting_Initiative+Fuel_consumption_from_renewable_sources_G4_EN3_b+General_Mills_Inc+2017
]

WEIRD_METRIC_ANSWERS = %w[
  Fairlabor+Fair_Labor_Participant+H_M+2015
  Fairlabor+Fair_Labor_Participant+Hanesbrands+2015
  Fairlabor+Fair_Labor_Participant+Nestle+2015
  Fairlabor+Fair_Labor_Participant+PVH+2015
  Global_Reporting_Initiative+Market_Presence_G4_EC5+3M_Company+2016
  Kelly_Ramirez+Country+2017
  Graph+Postobón_S_A+2017
  Kelly_Ramirez+Country+Backus+2015
  Amnesty_International+Apple_Inc+2015
  Amnesty_International+Acer_Inc+2015
  Amnesty_International+Apple_Inc+2016
  Amnesty_International+Xiaomi_Technology_Co_Ltd+2016
]

BAD_SEPARATORS = {
  "Clean_Clothes_Campaign+Factory_Disclosure" => ", ",
  "Walk_Free_Foundation+MSA_Identification_of_risks" => " and "
}

def fix_separators metric_name, separator
  Card[metric_name].researched_answers.each do |answer|
    val = answer.card.value_card
    val.content = val.content.gsub separator, "\n"
    val.save!
  end
end

NO_VALUE_NO_SOURCE.each do |answer_name|
  Card[answer_name]&.delete!
end

VALUE_IDS_WRONG.each do |answer_name|
  Card["#{answer_name}+value"]&.update! left_id: Card.fetch_id(answer_name)
end

NONSTANDARD_UNKNOWNS.each do |answer_name|
  Card["#{answer_name}+value"]&.update! content: "Unknown"
end

BAD_SEPARATORS.each do |metric_name, separator|
  fix_separators metric_name, separator
end

# prevent answer/value deletion from breaking from wacko metrics
def patch_weird_metric metric_card
  m_sing = metric_card.singleton_class
  m_sing.include Card::Set::Type::Metric
  m_sing.define_method(:hybrid?) { false }
  m_sing.define_method(:value_cardtype_code) { :free_text }
  m_sing.define_method(:relationship?) { false }
end

def patch_answer_with_weird_metric answer_card, metric_card
  answer_card.singleton_class.define_method(:metric_card) { metric_card }
  answer_card.value_card.singleton_class.define_method(:metric_card) { metric_card }
end

weird_metrics = []
WEIRD_METRIC_ANSWERS.each do |answer_name|
  next unless (answer_card = Card[answer_name])

  metric_card = Card[Card::Name.compose answer_name.to_name.parts[0..1]]
  patch_weird_metric metric_card
  patch_answer_with_weird_metric answer_card, metric_card

  answer_card.delete!
  weird_metrics << metric_card
end

weird_metrics.uniq.each &:delete!

MSA_METRIC = "Business_Human_Rights_Resource_Centre+Modern_Slavery_statement"
fixes = {}

def standardize_msa_content val
  case val
  when /^(\[\[)?no(\]\])?$/i
    "No - neither"
  else
    "Yes - UK Modern Slavery Act"
  end
end

Card[MSA_METRIC].researched_answers.each do |answer|
  acard = answer.card
  val = acard.value_card
  next if val.valid? || val.content.blank?

  v = fixes[cont] ||= standardize_msa_content(val.content)
  updates = { "+value":  v }
  updates[:"+checked_by"] = "[[request]]" if v.match? "Yes"

  acard.update! updates
end

Answer.where(answer_id: nil, metric_type_id: Card::Codename.id(:researched)).delete_all

Answer.where(
  "answer_id is not null and not exists " \
  "(select * from cards where cards.id = answer_id and cards.trash is false)"
).delete_all
