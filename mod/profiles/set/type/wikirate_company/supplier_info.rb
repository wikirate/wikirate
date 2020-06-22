format :json do
  view :supplier_info do
    supplier_info.to_json
  end
end

def supplier_info
  data = supplier_info_data
  hash = { name: name,
           link_name: name.url_key,
           country_name: country_name }.merge data
  hash[:present] = supplier_data_present? data
  hash
end

def supplier_data_present? hash
  hash.values.each do |v|
    if v.is_a? Hash
      return true if supplier_data_present? v
    else
      return true if v
    end
  end
  false
end

def supplier_info_data
  {
    workers_by_gender: workers_by_gender,
    workers_by_contract: workers_by_contract,
    average_net_wage: average_net_wage,
    wage_gap: wage_gap,
    workers_have_cba: workers_have_cba,
    workers_know_brand: workers_know_brand,
    workers_get_pregnancy_leave: workers_get_pregnancy_leave
  }
end

def country_name
  latest_value :core_country
end

def workers_by_gender
  {
    female: latest_value(:ccc_female_workers),
    male: latest_value(:ccc_male_workers),
    other: latest_value(:ccc_neither_male_or_female)
  }
end

def latest_value metric_code
  latest_answer(metric_code)&.value
end

def workers_by_contract
  {
    permanent: latest_value(:ccc_permanent_workers),
    temporary: latest_value(:ccc_temporary_workers)
  }
end

def average_net_wage
  latest_value :ccc_avg_net_worker_salary
end

def wage_gap
  latest_value :ccc_avg_wage_gap
end

def workers_have_cba
  latest_value :ccc_collective_bargaining_agreement
end

def workers_know_brand
  latest_value :ccc_surveyed_workers_who_know_which_brands_they_produce_for
end

def workers_get_pregnancy_leave
  latest_value :ccc_workers_who_had_pregnancy_leave
end
