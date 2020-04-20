# helper module for specs for classes that inherit from ImportItem
module ImportItemSpecHelper
  def item_hash args={}
    ITEM_HASH.merge args
  end

  def item_object hash=nil
    hash ||= item_hash
    described_class.new hash
  end

  def validate item_hash=nil
    item = item_object item_hash
    item.validate!
    item
  end

  def import item_hash=nil
    item = item_object item_hash
    item.import
    item
  end
end
