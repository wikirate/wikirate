format :json do
  def default_export_args args
    args[:count] ||= 0
    args[:count] += 1
    args[:processed_keys] ||= ::Set.new
  end

  view :export do |args|
    # avoid loops
    return [] if args[:count] > 5 || args[:processed_keys].include?(card.key)
    args[:processed_keys] << card.key
    Array.wrap(render_atom(args)).concat(
      render_export_items(args)
    ).flatten
  end

  def default_export_items_args args
    args[:processed_keys] ||= ::Set.new
  end

  view :export_items do |args|
    items_for_export(args[:processed_keys]).map do |item|
      subformat(item).render_export args
    end
  end

  def items_for_export processed_keys
    items = []
    card.each_nested_chunk do |chunk|
      next unless valid_export_chunk? chunk, processed_keys
      items << chunk.referee_card
    end
    items.compact.uniq
  end

  def valid_export_chunk? chunk, processed_keys
    return false if main_nest_chunk? chunk
    return false unless (r_card = chunk.referee_card)
    return false if r_card.new? || r_card == card
    return false if processed_keys.include? r_card.key
    true
  end

  def main_nest_chunk? chunk
    chunk.respond_to?(:options) &&
      chunk.options &&
      chunk.options[:nest_name] &&
      chunk.options[:nest_name] == "_main"
  end
end
