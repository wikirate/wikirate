include_set Abstract::Calculation
include_set Abstract::Hybrid

format :html do
  def tab_list
    %i[details score project]
  end
end
