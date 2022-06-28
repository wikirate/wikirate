assign_type :pointer

def option_names
  %w[publication dashboard]
end

format :html do
  def input_type
    :radio
  end
end
