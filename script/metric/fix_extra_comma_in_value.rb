require File.expand_path('../../../config/environment',  __FILE__)

Card::Auth.current_id = Card.fetch_id "Richard Mills"
Card::Auth.as_bot do
  wql = {
          :type_id=>Card::MetricValueID,
          :left=>{
            :left=>"Good Company Index+Good Company Grade"
          },
          :right_plus=>["value",{:content=>["match",","]}],
          :append=>"value"
        }
  extra_comma_metric_value = Card.search wql
  extra_comma_metric_value.each do |metric_value|
    content = metric_value.content
    new_content = content.gsub(",","")
    puts "update #{metric_value.name} from #{metric_value.content} to #{new_content}"
    metric_value.content = new_content
    metric_value.save!
  end
end