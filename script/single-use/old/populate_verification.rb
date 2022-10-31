# SPDX-FileCopyrightText: 2014 2014 Laureen van Breen, <laureen@wikirate.org> et al.
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

Answer.update_all verification: 1

batch = 0
Answer.where("answer_id is not null").in_batches do |answers|
  Card::Cache.renew
  batch += 1
  puts "answers batch: #{batch}"
  answers.each do |a|
    a.refresh :verification
    next if a.verification == 1

    a.update_related_verifications
  end
end
