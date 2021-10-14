# not to be stored - year is in name
include_set Abstract::Pointer

def option_names
  Type::Year.all_years
end

format :html do
  def input_type
    card.content = card.name.left_name.right # default to current answer year
    :select
  end
end
