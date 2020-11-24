include_set Abstract::Chart

def chartable_type?
  relationship? || numeric? || categorical?
end

format :html do
  delegate :chartable_type?, to: :card

  def show_chart?
    super && chartable_type?
  end
end