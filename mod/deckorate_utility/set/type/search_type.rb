def new_relic_label
  codename || (compound? ? "R_#{name.right_name.key}" : name.key)
end
