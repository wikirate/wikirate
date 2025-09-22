assign_type :pointer

LICENSES = [
  "CC BY 4.0",
  "CC BY-SA 4.0",
  "CC BY-NC 4.0",
  "CC BY-NC-SA 4.0",
  "CC BY-ND 4.0",
  "CC BY-NC-ND 4.0"
].freeze

def virtual?
  new?
end

def content
  new? ? "CC BY 4.0" : super
end

def ok_to_update?
  Auth.current.stewards_all?
end

def ok_to_create?
  Auth.current.stewards_all?
end

def options_hash
  LICENSES.each_with_object({}) { |name, hash| hash[name] = name }
end

def nonderivative?
  content.match?(/ND/)
end

def nonderivative_licenses
  LICENSES.select { |l| !l.match?(/ND/) }
end

def noncommercial?
  content.match?(/NC/)
end

def noncommercial_licenses
  LICENSES.select { |l| !l.match?(/NC/) }
end

# find the most permissive license that is compatible with the input licenses
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

format do
  def url
    dir = card.content.gsub(/(CC|4.0)/, "").strip.downcase
    "https://creativecommons.org/licenses/#{dir}/4.0"
  end

  view :attribution do
    "licensed under #{card.content} <#{url}>"
  end
end

format :html do
  def input_type
    :select
  end

  def license_link
    link_to card.content, href: url, target: "_blank"
  end

  view :core do
    "#{license_link} #{subformat(card.left).attribution_link}"
  end

  view :attribution do
    "licensed under #{license_link}"
  end
end
