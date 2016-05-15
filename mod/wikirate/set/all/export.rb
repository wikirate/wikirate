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
    result = []
    each_nested_chunk do |chunk|
      next if chunk.respond_to?(:options) && chunk.options &&
              chunk.options[:inc_name] &&
              chunk.options[:inc_name] == '_main'
      next unless (r_card = chunk.referee_card)
      next if r_card.new? || r_card == card
      next if args[:processed_keys].include?(r_card.key)
      result << r_card
    end
    result.compact.uniq.map { |ca| subformat(ca).render_export(args) }
  end
end

