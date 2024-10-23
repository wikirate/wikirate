require File.expand_path "../../../config/environment", __FILE__
require "colorize"

user = Rails.env.development? ? "Joe Admin" : "Ethan McCutchen"
Card::Auth.signin user

MAP = {
  "Civil Society / NGO" => "Civil Society Organization (CSO)",
  "Independent" => "Data enthusiast",
  "Investor AB" =>  "Investment",
  "Media" => "Media or Journalism",
  "Student" =>  "Studies",
  "Trade Union" => "Labor union"
}

def academic user
  researcher_ids.include?(user.id) ? "Studies" : "Teaching"
end

def researcher_ids
  @researcher_ids ||= ::Set.new(
    Card.search referred_to_by: { left: { type: :research_group }, right: :researcher },
                return: :id
  )
end

Card.search right: :profile_type do |pt|
  new_type = pt.content == "Academic" ? academic(pt.left) : MAP[pt.content]
  puts "#{pt.content} --> #{new_type}"
  pt.update! content: new_type if new_type.present?
end
