def filter_hash
  backwards_compatibility_filtering { super }
end

def backwards_compatibility_filtering
  hash = yield
  if (status = hash.delete :metric_value)
    hash[:status] = status
  end
  hash
end

format :html do
  def filter_view
    :content
  end

  def filter_selector
    ".RIGHT-answer.content-view"
  end
end
