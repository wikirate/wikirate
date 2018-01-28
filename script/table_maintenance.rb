#!/usr/bin/env ruby

require File.dirname(__FILE__) + "/../config/environment"

def tables
  @tables ||= exec_query("show tables").map &:first
end

def exec_query query
  ActiveRecord::Base.connection.execute query
end

def optimize_table table
  exec_query "OPTIMIZE TABLE #{table}"
end

def reindex_table table
  exec_query "ALTER TABLE #{table} ENGINE=INNODB;"
end

tables.each do |table|
  optimize_table table
  reindex_table table
end