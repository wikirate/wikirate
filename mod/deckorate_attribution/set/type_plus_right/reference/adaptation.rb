include_set Abstract::IdList

assign_type :pointer

def option_names
  %i[no_adaptation yes_adaptation].map(&:cardname)
end

format :html do
  def input_type
    :radio
  end
end
