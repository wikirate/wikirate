include_set Abstract::Search
include_set Abstract::Utility
include_set Abstract::Filter
include_set Abstract::FilterFormgroups

def virtual?
  true
end

format do
  def paging_view
    :content
  end
end
