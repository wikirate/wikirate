
class << self
  def member_ids
    @member_ids ||= Card.search return: :id,
                                right_plus: [:roles, refer_to: WikirateTeamID]
  end

  def member?
    member_id_hash[Card::Auth.current_id]
  end

  private

  def member_id_hash
    @member_id_hash ||= member_ids.each_with_object({}) do |member_id, hash|
      hash[member_id] = true
    end
  end
end
