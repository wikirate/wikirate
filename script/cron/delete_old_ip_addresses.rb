#!/usr/bin/env ruby

# SPDX-FileCopyrightText: 2022 WikiRate info@wikirate.org
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.expand_path("../../../config/environment", __FILE__)

Card::Act.where("acted_at < ?", 6.months.ago).update_all ip_address: nil
