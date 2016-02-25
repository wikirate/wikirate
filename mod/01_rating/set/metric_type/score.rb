include Set::Abstract::Calculation

def normalize_value value
  return 0 if value < 0
  return 10 if value > 10
  value
end


format :html do
  view :new_tab_pane do
    'Score'
  end
end
