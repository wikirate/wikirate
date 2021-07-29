class << self
  def always_ids
    @always_ids ||= Card.search(
      right_plus: [:roles, refer_to: [:in, WikirateTeamID, StewardID]],
      return: :id
    )
  end
end
