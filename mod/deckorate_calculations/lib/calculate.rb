# module for organizing Calculator and Input classes
class Calculate
  include Clean

  attr_reader :records, :metric

  def initialize metric, args={}
    @metric = metric
    @company_id = args[:company_id]
    @year = args[:year]
    @records = metric.records args
  end

  def prepare
    # stash the following
    old_company_ids
    expirables
    overridden_hash
  end

  def transact
    wipe_old_calculations
    process_calculations do |not_overridden, overridden|
      insert_calculations not_overridden
      update_overridden_calculations overridden
    end
  ensure
    metric.update_latest @company_id
  end

  private

  def old_company_ids
    @old_company_ids ||= unique_company_ids
  end

  def unique_company_ids
    array = if @company_id
              [@company_id]
            else
              records.select(:company_id).distinct.pluck :company_id
            end
    ::Set.new array
  end

  def wipe_old_calculations
    records.where(record_id: nil).delete_all if old_company_ids.present?
    return unless overridden_hash.present?

    records.where("record_id is not null").update_all overridden_value: nil
  end

  def expirables
    return [] unless old_company_ids.present?

    @expirables ||= records.joins("JOIN cards AS companies ON company_id = companies.id")
                           .pluck :name, :year
  end

  def overridden_hash
    return {} unless old_company_ids.present?

    @overridden_hash ||= records.where("record_id is not null")
                                .pluck(:company_id, :year)
                                .each_with_object({}) do |(c, y), h|
      h["#{c}-#{y}"] = true
    end
  end

  def results
    metric.calculator.result companies: @company_id, years: @year
  end

  def process_calculations
    calcs = calculations
    yield calcs[:not_overridden], calcs[:overridden]
  end

  def overridden? calc
    overridden_hash["#{calc.company_id}-#{calc.year}"]
  end

  def calculations
    results.each_with_object(overridden: [], not_overridden: []) do |calc, hash|
      (overridden?(calc) ? hash[:overridden] : hash[:not_overridden]) << calc
    end
  end

  def insert_calculations calcs
    attribs = calcs.map { |calc| calc.record_attributes.merge metric_id: metric.id }
    attribs.each_slice(5000) { |slice| Record.insert_all slice }
  end

  def update_overridden_calculations overridden
    overridden.each do |o|
      records.where(company_id: o.company_id, year: o.year)
             .update_all overridden_value: o.value
    end
  end
end
