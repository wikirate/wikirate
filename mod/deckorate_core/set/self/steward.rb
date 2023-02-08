class << self
  def always_ids
    @always_ids ||= Card.search(
      referred_to_by: { left_id: [:in, WikirateTeamID, StewardID], right: :members },
      return: :id
    )
  end
end
