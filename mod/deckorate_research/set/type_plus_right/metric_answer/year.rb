# not to be stored - year is in name
include_set Abstract::List

event :do_not_save_answer_year, :validate, on: :save do
  abort :success
end

def option_names
  Type::Year.all_years
end

format :html do
  def input_type
    card.content = card.name.left_name.right # default to current answer year
    :select
  end
end
