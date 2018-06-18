include_set Abstract::Thumbnail

format :html do
  def thumbnail_subtitle_text
    field_nest :headquarters, view: :core, items: { view: :name }
  end
end
