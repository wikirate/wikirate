include_set Type::MultiCategoryValue

json_file_path = ::File.expand_path "../../../data/classes.json", __FILE__
ISIC_INDUSTRY_CLASSES = JSON.parse ::File.read(json_file_path)

format :html do
  def editor
    :multiselect
  end

  def options_hash
    ISIC_INDUSTRY_CLASSES.each_with_object({}) do |(code, text), hash|
      hash["#{code}: #{text}"] = code
    end
  end

  def multiselect_input
    select_tag "pointer_multiselect-#{unique_id}", options_for_select(options_hash),
               multiple: true, class: "pointer-multiselect form-control"
  end
end
