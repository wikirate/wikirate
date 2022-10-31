#!/usr/bin/env ruby

# SPDX-FileCopyrightText: 2014 2014 Laureen van Breen, <laureen@wikirate.org> et al.
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.dirname(__FILE__) + "/../config/environment"
Card::Auth.signin Card::WagnBotID

Card::Reference.repair_all
