UNKNOWN = "Unknown".freeze

event :unknown_value, :initialize, when: ->(c) { c.subfield(:unknown) } do
  self.content = UNKNOWN if subfield(:unknown).checked?
  detach_subfield :unknown
end

def value_unknown?
  content == UNKNOWN
end
