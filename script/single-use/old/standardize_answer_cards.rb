# SPDX-FileCopyrightText: 2014 2014 Laureen van Breen, <laureen@wikirate.org> et al.
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

# correct answer names (eg by removing underscores)
Card.where(type_id: Card::MetricAnswerID).find_each do |answer|
  standard = answer.name.standard

  if answer.name.to_s != standard.to_s
    answer.update_column :name, standard
  end
end

# get rid of structured content in structured cards (because most of it is old or
# nonsense, and it includes a lot of errors)
types = %i[wikirate_company metric_title wikirate_topic metric metric_answer project]
types << "Ticket"
type_ids = types.map(&:code_id)

Card.where("type_id in (#{type_ids * ', '})").update_all(db_content: "")
