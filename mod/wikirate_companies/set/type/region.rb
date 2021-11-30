card_accessor :country, type: :pointer

def oc_code
  field(:oc_jurisdiction_key)&.oc_code
end
