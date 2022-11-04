include_set Abstract::Delist

card_accessor :country, type: :pointer

def oc_code
  fetch(:oc_jurisdiction_key)&.oc_code
end
