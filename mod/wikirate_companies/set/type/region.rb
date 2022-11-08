include_set Abstract::Delist

card_accessor :country, type: :pointer
card_accessor :country_code, type: :pointer
card_accessor :ilo_region, type: :pointer

def ok_to_update
  Auth.always_ok?
end

def oc_code
  fetch(:oc_jurisdiction_key)&.oc_code
end
