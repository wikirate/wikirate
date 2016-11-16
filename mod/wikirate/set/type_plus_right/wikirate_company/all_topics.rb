include_set Abstract::SortAndFilter



def raw_content
  %({
    "type_id": "#{WikirateTopicID}",
    "referred_to_by":{
      "left": {
        "type_id":"#{MetricID}",
        "right_plus": ["_1", {}]
      },
      "right_id": "#{WikirateTopicID}"
    }
  })
end
