# event :ensure_codename, :validate do
#   return if codename.present?
#   errors.add :codename, "jurisdiction needs to have a codename"
# end

def oc_code
  content[3..-1].to_sym
end
