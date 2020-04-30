def new_relic_label
  codename || (junction? ? name.right_name : name)
end
