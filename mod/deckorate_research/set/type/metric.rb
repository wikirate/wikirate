def community_assessed?
  researched? && research_policy&.downcase == "community assessed"
end
