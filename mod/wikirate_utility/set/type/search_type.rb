def new_relic_label
  codename || (junction? ? "R_#{name.right_name.key}" : name.key)
end
