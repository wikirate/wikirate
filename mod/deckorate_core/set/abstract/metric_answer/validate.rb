# NOTE: name validations are in name.rb

def source_required?
  standard? || hybrid?
end

# TODO: find this a better home
def number? str
  true if Float(str)
rescue StandardError
  false
end
