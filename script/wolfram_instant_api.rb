#!/usr/bin/env ruby

puts "what?"

require File.expand_path "../../config/environment", __FILE__

Card::Auth.as_bot

def ilo_regions
  Card.search(left: { type: "Region" }, right: "ILO Region").map do |card|
    %("#{card.name.left}" ->  "#{card.content}")
  end
end

puts <<-WOLFRAM

CloudDeploy[
  APIFunction[
    {"expr"->"String"},
    ResponseForm[
      Zeros = Function[a, Count[a, 0]];
      Unknowns = Function[a, Count[a, "Unknown"]];
      ILORegions = <| #{ilo_regions.join ", "} |>;
      ToExpression[#expr],"JSON"
    ] &
  ],  
  Permissions -> "Public"   
]

WOLFRAM
