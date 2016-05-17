card_accessor :direct_contribution_count, type: :number, default: "0"

format :html do
  def view_caching?
    true
  end
end
