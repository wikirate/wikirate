def import_counts
  return @ic if @ic
  @ic = Hash.new 0
  @ic[:imported], @ic[:failed], @ic[:total] =
    item_names.first&.split("/")&.map(&:to_i)
  @ic
end

def percentage key
  return 0 if count(:total) == 0 || count(key).nil?
  (count(key) / count(:total).to_f * 100).to_i
end

def count key
  import_counts[key]
end


format :html do
  delegate :percentage, :count, to: :card

  def wrap_data
    super.merge "refresh-url" => path(view: @slot_view)
  end

  def wrap_classes slot
    class_up "card-slot", "_refresh-timer", true if importing?
    super
  end

  def auto_refresh?
    @slot_view.in?([:open, :content, :titled]) && importing?
  end

  def importing?
    count(:imported) + count(:failed) < count(:total)
  end

  def item_count_label count_key
    label = card.left&.try(:item_label) || "card"
    label = label.pluralize if count(count_key) > 1
    "#{count(count_key)} #{label}"
  end

  def progress_header
    if importing?
      "Importing #{item_count_label :total} ..."
    else
      "Imported #{item_count_label :imported}"
    end
  end

  view :core do
    with_header progress_header, level: 4 do
      progress_bar progress_section(:imported, :success),
                   progress_section(:failed, :danger)
    end
  end

  def progress_section type, context
    html_class = "bg-#{context}"
    html_class << " progress-bar-striped progress-bar-animated" if importing?
    { value: percentage(type), label: "#{count(type)} #{type}", class: html_class }
  end

  view :errors do

  end
end
