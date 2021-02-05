VERIFICATION_LEVEL = [
  { name: :flagged, icon: :flag, color: :red, title: "check requested" },
  { name: :unverified, color: :grey, title: "answer unverified" },
  { name: :community, color: :blue, title: "verified by community" },
  { name: :steward, color: :gold, title: "verified by steward" }
].freeze

def imported?
  answer.imported || false
end

def verification_index symbol
  VERIFICATION_LEVEL.index { |v| v[:name] == symbol }
end

def verification_hash index
  VERIFICATION_LEVEL[index]
end

def verification_level
  if metric_card.designer_assessed?
    verification_index :steward
  elsif researched_value?
    checked_by_card.verification_level
  else

    # calculated_verification_level
    1
  end
end

def current_verification_hash
  # verification_hash card.answer.verification_level
  verification_hash verification_level
end

format :html do
  def flag_names
    %i[verification imported] << super
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
