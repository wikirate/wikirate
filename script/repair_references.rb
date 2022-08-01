#!/usr/bin/env ruby

# SPDX-FileCopyrightText: 2022 WikiRate info@wikirate.org
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.dirname(__FILE__) + "/../config/environment"
Card::Auth.signin Card::WagnBotID

Card::Reference.repair_all
