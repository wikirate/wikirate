include_set Abstract::Table
include_set Abstract::ListCachedCount
include_set Abstract::DatasetScope

def hereditary_field?
  false
end

def item_names _args={}
  super.reverse
end

format :html do
  def input_type
    :multiselect
  end
end
