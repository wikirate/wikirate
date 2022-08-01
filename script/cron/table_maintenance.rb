#!/usr/bin/env ruby

# SPDX-FileCopyrightText: 2022 WikiRate info@wikirate.org
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.expand_path("../../../config/environment", __FILE__)

def tables
  @tables ||= exec_query("show tables").map(&:first)
end

def exec_query query
  ActiveRecord::Base.connection.execute query
end

def optimize_table table
  exec_query "OPTIMIZE TABLE #{table}"
end

def analyze_table table
  exec_query "ANALYZE TABLE #{table}"
end

def reindex_table table
  exec_query "ALTER TABLE #{table} ENGINE=INNODB;"
end

tables.each do |table|
  analyze_table table
  # optimize_table table
  reindex_table table
end
