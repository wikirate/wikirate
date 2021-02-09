VERIFICATION_LEVELS = [
  { name: :flagged, icon: :flag, color: :red, title: "Check Requested" },
  { name: :unverified, color: :grey, title: "Answer Unverified" },
  { name: :community, color: :blue, title: "Verified by Community" },
  { name: :steward, color: :gold, title: "Verified by Steward" }
].freeze

def imported?
  answer.imported || false
end

# @params [Symbol] symbol
# @return [Integer] matching given verification level symbol
#  (:flagged -> 0, :unverified -> 1, ...)
def verification_index symbol
  VERIFICATION_LEVELS.index { |v| v[:name] == symbol }
end

# @params [Integer] index
# @return [Hash] with name, color, title, and (sometimes) icon for given
# verification index
def verification_hash index
  VERIFICATION_LEVELS[index]
end

# @return [Integer] current verification index
def verification
  if metric_card.designer_assessed?
    verification_index :steward
  elsif researched_value?
    checked_by_card.verification
  elsif relationship?
    1 # hard-code unverified for now
  else
    calculated_verification
  end
end
alias :current_verification_index :verification

# @return [Hash]
def current_verification_hash
  # verification_hash card.answer.verification
  verification_hash verification
end

format :html do
  def flag_names
    %i[verification imported] + super
  end

  def verification_flag
    return unless (h = card.current_verification_hash)

    icon = h[:icon] || "check-circle"
    fa_icon icon, class: "verify-#{h[:color]}", title: h[:title]
  end

  def imported_flag
    card.imported? ? icon_tag("upload", library: :font_awesome, title: "imported") : ""
  end
end
