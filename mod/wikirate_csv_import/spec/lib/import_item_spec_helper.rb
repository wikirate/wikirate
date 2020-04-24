# helper module for specs for classes that inherit from ImportItem
module ImportItemSpecHelper
  def item_hash args={}
    default_item_hash.merge args
  end

  def item_object hash={}
    described_class.new item_hash(hash)
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
end
