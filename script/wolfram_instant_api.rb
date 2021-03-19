#!/usr/bin/env ruby

# For now, the way this works is
#
# 1. we run this script on a copy of the site with current geo data (using bundle exec)
#
# 2. we cut and paste the API string into Wolfram Cloud:
#    https://www.wolframcloud.com/env/philipp.kuehl/wikirate.nb
#
# 3. we update the server configuration with the new object identification:
#     config.wolfram_api_key = "adfsadf-asdfsad-asdfsa-dfsdfds"
#
# Soon we would like to automate the update...
#
require File.expand_path "../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

def region_fields field
  Card.search(left: { type: "Region" }, right: field).map do |card|
    yield card
  end
end

def region_association field
  key_vals = region_fields(field) { |f| %("#{f.name.left}" ->  "#{f.content}") }
  "<| #{key_vals.join ', '} |>"
end

puts <<~WOLFRAM

  ILORegion = #{region_association 'ILO Region'};
  Country = #{region_association 'Country'};
  Zeros = Function[a, Count[a, 0]];
  Unknowns = Function[a, Count[a, "Unknown"]];

  CloudDeploy[
    APIFunction[
      {"expr"->"String"},
      ResponseForm[
        (
          Zeros = Zeros;
          Unknowns = Unknowns;
          ILORegion = ILORegion;
          Country = Country;
          ToExpression[#expr]
        ), "JSON"
      ] &,
      "JSON"
    ],
    Permissions -> "Public"
  ]

WOLFRAM
