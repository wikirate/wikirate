assign_type :pointer

def option_names
  Self::Output::OUTPUT_TYPE_OPTIONS
end

format :html do
  def input_type
    :radio
  end
end
