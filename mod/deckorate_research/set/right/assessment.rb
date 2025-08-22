include_set Abstract::StewardPermissions
include_set Abstract::SingleItem

assign_type :pointer

def ok_item_types
  :assessment
end

format :html do
  def input_type
    :select
  end
end
