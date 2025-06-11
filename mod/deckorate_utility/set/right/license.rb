assign_type :pointer

def virtual?
  new?
end

def content
  new? ? "CC BY 4.0" : super
end

def ok_to_update?
  Auth.stewards_all?
end

def ok_to_create?
  Auth.stewards_all?
end

def options_hash
  ["CC BY 4.0",
   "CC BY-SA 4.0",
   "CC BY-NC 4.0",
   "CC BY-NC-SA 4.0",
   "CC BY-ND 4.0",
   "CC BY-ND-SA 4.0"
  ].each_with_object({}) do |name, hash|
    hash[name] = name
  end
end

def compatible licenses
  bits = licenses.map { |license| license.split(/[-\s]/) }.flatten.uniq.join " "
  license = "CC BY"
  license += "-NC" if bits.match? "NC"
  if bits.match? "ND"
    license += "-ND"
  elsif bits.match? "SA"
    license += "-SA"
  end
  license + " 4.0"
end

format :html do
  def input_type
    :select
  end
end