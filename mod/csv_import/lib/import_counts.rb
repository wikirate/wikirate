#! no set module

class ImportCounts < Hash
  def initialize hash
    hash ||= {}
    replace hash
  end

  def default key
    0
  end

  def count key
    self[key]
  end

  def step key
    self[key] += 1
  end

  def percentage key
    return 0 if count(:total) == 0 || count(key).nil?
    (count(key) / count(:total).to_f * 100).floor(2)
  end

  def to_card_content
    to_json
  end

  def reset total
    replace total: total
    update_attributes content: to_card_content
  end

end

