def subvariants
  { created: [:submitted, :organized] }
end

def created_query user_id, variant=nil
  case variant
  when :submitted
    { created_by: user_id }
  when :organized
    { right_plus: [OrganizerID, { refer_to: user_id }] }
  else
    { or:
        created_query(user_id, :submitted).merge(
          created_query(user_id, :organized)
        ) }
  end
end

format :html do
  view :titled_content do
    [field_nest(:description), render_add_button, research_groups]
  end

  def research_groups
    field_nest :browse_research_group_filter, view: :filtered_content
  end
end
