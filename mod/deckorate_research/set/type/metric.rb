def community_assessed?
  researched? && assessment&.downcase == "community assessed"
end
