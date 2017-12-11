def followable?
  false
end

def history?
  false
end

def status
  @status ||= ImportManager::Status.new content
end

def import_counts
  @import_counts ||= status[:counts]
end

def reset total
  @status = ImportManager::Status.new act_id: ActManager.act&.id, counts: { total: total }
  save_status
end

def step key
  import_counts.step key
  save_status
end

def save_status
  update_attributes content: status.to_json
end

STATUS_HEADER = {
  failed: "Failed",
  imported: "Successful",
  overridden: "Overridden",
  skipped: "Skipped"
}.freeze

STATUS_CONTEXT = {
  failed: :danger,
  imported: :success,
  overridden: :warning,
  skipped: :info
}.freeze

format :html do
  delegate :status, :import_counts, to: :card
  delegate :percentage, :count, :step, to: :import_counts

  def wrap_data slot=true
    super(slot).merge "refresh-url" => path(view: @slot_view)
  end

  def wrap_classes slot
    class_up "card-slot", "_refresh-timer", true if auto_refresh?
    super
  end

  def auto_refresh?
    @slot_view.in?([:open, :content, :titled]) && importing?
  end

  def importing?
    STATUS_CONTEXT.keys.inject(0) do |sum, key|
      sum + count(key)
    end < count(:total)
  end

  # returns plural if there are more than one card of type `count_type`
  def item_label count_type=nil
    label = card.left&.try(:item_label) || "card"
    count_type && count(count_type) > 1 ? label.pluralize : label
  end

  def item_count_label count_key
    label = item_label count_key
    "#{count(count_key)} #{label}"
  end

  def progress_header
    if importing?
      "Importing #{item_count_label :total} ..."
    elsif count(:overridden).positive?
      "#{item_count_label :imported} created and " \
      "#{item_count_label :overridden} updated" \
    else
      "Imported #{item_count_label(:imported)}"
    end
  end

  view :core do
    with_header(progress_header, level: 4) do
      sections = %i[imported skipped overridden failed].map do |type|
        progress_section type
      end.compact
      progress_bar(*sections)
    end + wrap_with(:p, undo_button) + wrap_with(:p, report)
  end

  def report
    [:failed, :skipped, :overridden, :imported].map do |key|
      next unless status[key].present?
      generate_report_alert key
    end.compact.join
  end

  def generate_report_alert type
    alert STATUS_CONTEXT[type], false, false, href: "##{type}" do
      with_header STATUS_HEADER[type], level: 5 do
        list = []
        status[type].each do |index, name|
          list << report_line(index, name, type)
        end
        list_group list
      end
    end
  end

  def report_line index, name, type
    label, status_key =
      type == :failed ? [name, :errors] : [link_to_card(name), :reports]

    text = "##{index + 1}: #{label}"
    if status[status_key][index].present?
      text += " - " if name.present?
      text += status[status_key][index].join("; ")
    end
    text
  end

  def progress_section type
    return if count(type).zero?
    html_class = "bg-#{STATUS_CONTEXT[type]}"
    html_class << " progress-bar-striped progress-bar-animated" if importing?
    { value: percentage(type), label: "#{count(type)} #{type}", class: html_class }
  end

  def undo_button
    return if importing?
    return "" unless status[:act_id] && (act = Card::Act.find(status[:act_id]))
    wrap_with :div, class: "d-flex flex-row-reverse" do
      card.left.format(:html)
          .revert_actions_link act, "Undo",
                               revert_to: :previous,
                               html_args: { class: "btn btn-danger",
                                            "data-confirm" => undo_confirm_message }
    end
  end

  def undo_confirm_message
    text = "Do you really want to remove the imported #{item_label :imported}"
    if count(:overridden).positive?
      text += " and restore the overridden " + item_label(:overridden)
    end
    text << "?"
  end
end
