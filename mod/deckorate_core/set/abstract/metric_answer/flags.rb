include_set Abstract::Flaggable

delegate :open_flags, to: :lookup

format :html do
  view :flags do
    flags
  end

  view :small_flags do
    flags.map { |flag| "<small>#{flag}</small>" }
  end

  def flag_names
    [:comment]
  end

  def flags
    flag_names.map { |flag_name| send "#{flag_name}_flag" }
  end

  def comment_flag
    # the following will work once relationships have answer lookups
    # return "" unless card.lookup&.comments&.present?
    # fa_icon :comment, title: "Has comments"
    field_nest :discussion, view: :flag
  end
end
