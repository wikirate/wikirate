def company_group_lists
  Card.search type: :company_group,
              right_plus: [:specification, { refer_to: id }],
              append: :company
end
