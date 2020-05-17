format :json do
  view :supplier_info do
    supplier_info.to_json
  end
end

def supplier_info
  { name: name,
    workers_by_gender: workers_by_gender,
    workers_by_contract: workers_by_contract,
    average_net_wage: average_net_wage,
    wage_gap: wage_gap,
    workers_have_cba: workers_have_cba,
    workers_know_brand: workers_know_brand,
    workers_get_pregnancy_leave: workers_get_pregnancy_leave
  }
end


  def workers_by_gender
    {
        female: latest_value(:ccc_female_workers),
        male: latest_value(:ccc_male_workers),
        other: 100
    }
  end
  
  def latest_value metric_code
    latest_answer(metric_code)&.value
  end

  def workers_by_contract
    {
        permanent: 5,
        temporary: 2
    }
  end

  def average_net_wage
    1000
  end

  def wage_gap
    123
  end

  def workers_have_cba
    "yes"
  end

  def workers_know_brand
    "no"
  end

  def workers_get_pregnancy_leave
    "sometimes"
  end