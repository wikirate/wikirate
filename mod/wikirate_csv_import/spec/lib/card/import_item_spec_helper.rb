# helper module for specs for classes that inherit from ImportItem
module Card::ImportItemSpecHelper
  def item_name args={}
    item_name_from_args item_hash(args), item_name_parts
  end

  def item_hash args={}
    default_item_hash.merge args
  end

  def item_object hash={}
    obj = described_class.new item_hash(hash)
    obj.conflict_strategy = :override if @overriding
    obj
  end

  def validate item_hash={}
    item = item_object item_hash
    item.validate!
    item
  end

  def import item_hash={}
    item = item_object item_hash
    item.import
    item
  end

  def overriding
    @overriding = true
    yield
  end

  # TODO: generalize for use in imports that aren't answer imports
  def default_map
    default_item_hash.each_with_object({}) do |(column, val), hash|
      next if column.in? %i[value comment]
      hash[column] = { val => Card.fetch_id(val) }
    end
  end

  private

  def item_name_from_args args, keys
    Card::Name[keys.map { |k| args[k] }]
  end
end
