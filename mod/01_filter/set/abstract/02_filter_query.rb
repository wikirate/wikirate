class Filter
  def initialize filter_keys_with_values, extra_wql={}
    @filter_wql = Hash.new { |h, k| h[k] = [] }
    @rules = yield if block_given?
    @rules ||= {}
    @filter_keys_with_values = filter_keys_with_values
    @extra_wql = extra_wql
    prepare_filter_wql
  end

  def add_to_wql key, value
    @filter_wql[key] << value
  end

  def add_rule key, value
    case @rules[key]
    when Symbol
      send("#{@rules[key]}_rule", key, value)
    when Proc
      @rules[key].call(key, value).each do |wql_key, value|
        @filter_wql[wql_key] << value
      end
    else
      send("#{key}_wql", value)
    end
  end

  def to_wql
    @wql = {}
    @filter_wql.each do |wql_key, values|
      next if values.empty?
      case wql_key
      when :right_plus, :left_plus, :type
        and_merge wql_key, values
      else
        array_merge wql_key, values
      end
    end
    @wql.merge @extra_wql
  end

  private

  def prepare_filter_wql
    @filter_keys_with_values.each  do |key, values|
      add_rule key, values
    end
  end

  def array_merge wql_key, values
    if values.size.one?
      @wql[wql_key] = values.first
    else
      @wql[wql_key] = values
    end
  end

  def and_merge wql_key, values
    hash = and_merge_hash wql_key, values
    and_cond = hash.delete :and
    if and_cond.present?
      @wql[:and] ||= {}
      @wql[:and].merge! and_cond
    end
    @wql.merge! hash
  end

  def and_merge_hash
    return { key: values[0] } if values.size.one?
    val = values.pop
    { key => val,
      and: and_merge_hash(key, values) }
  end


  def name_wql name
    return unless name.present?
    @filter_wql[:name] = ["match", name]
  end

  def project_wql project
    return unless project.present?
    @filter_wql[:referred_to_by] << { left: { name: project } }
  end

  def industry_wql industry
    return unless industry.present?
    @filter_wql[:left_plus] << [
      industry_metric_name,
      { right_plus: [
        industry_value_year,
        { right_plus: ["value", { eq: industry }] }
      ] }
    ]
  end

  def industry_metric_name
    "Global Reporting Initiative+Sector Industry"
  end

  def industry_value_year
    "2015"
  end
end

def search_wql type_id, opts, params_keys, return_param=nil, &block

  wql = { type_id: type_id }
  wql[:return] = return_param if return_param
  FilterAndSort.new(filter_keys_with_values, Env.params[:sort], wql, &wql).to_wql
  # params_keys.each do |key|
  #   # link_to in #page_link with name will override the path
  #   method_name = key.include?("_name") ? "name" : key
  #   send("wql_by_#{method_name}", wql, opts[key])
  # end
  # wql
end

