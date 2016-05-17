# -*- encoding : utf-8 -*-

class NewMetricValueRepresentation < Card::Migration
  def up
    Card.create! :name=>"Metric value", :codename=>"metric_value", :type_code=>:cardtype
    Card.create! :name=>"Metric value+*type+*structure", :content=>"{{+value}}\n{{+source}}\n{{+discussion}}"
    card = Card[:values]
    card.update_attributes! :codename=>"value", :subcards=>{
      "+*right+*default"=>{:type_id=>Card::PhraseID}
    }
    card = Card.fetch "values+*right+*structure"
    card.update_attributes! :name=>"metric values+*right+*structure"
    card = Card.fetch "metric details+*right+*structure"
    card.update_attributes! :content=> %{
<div class="metric-info">
  <div class="row">
    <div class="row-icon">
      <i class="fa fa-building-o"></i>
    </div>
    <div class="row-data">
      {{_1+logo|core;size:icon}}
      {{_1|link}}
    </div>
  </div>
  <div class="row">
    <div class="row-icon">
      <i class="fa fa-question"></i>
    </div>
    <div class="row-data">
      {{_ll+about|core}} [[_ll|Metric Details]]
    </div>
  </div>
  <div class="row">
    <div class="row-icon">
      <i class="fa fa-tag"></i>
    </div>
    <div class="row-data">
      {{_ll+topics|content|link}}
    </div>
  </div>
  {{#_ll+methodology}}
</div>
<div class="timeline">
  <div class="timeline-header">
    <div class="th year">
      Year
    </div>
    <div class="th value">
      Value
    </div>
    <div class="th new">
      [[_ll|+ Add New]]
    </div>
  </div>
  <div class="timeline-body">
    {{_l+metric values|timeline}}
  </div>
</div>
}

    card = Card.fetch "metric value timeline item"
    card.update_attributes! :content => %{
<div class="timeline-row">
  <div class="year td">
  {{_right|name}}
</div>
<div class="timeline-dot"></div>
<div class="timeline-line"></div>
<div class="value td">{{_self+value|content}}</div>
<div class="credit td">{{_self|structure:creator credit}}</div>
</div>
}
    Card::Cache.reset_all
    metric_values = Card.search :right=>{:type_id=> Card::YearID}, :left=>{:right=>{:type_id=>Card::WikirateCompanyID}, :left=>{:type_id=>Card::MetricID }}
    metric_values.each do |value_card|
      value_card.update_attributes! :type_id=>Card::MetricValueID, :subcards=>{"+value"=>{:type_code=>:phrase, :content=>value_card.content}}
    end
  end
end
