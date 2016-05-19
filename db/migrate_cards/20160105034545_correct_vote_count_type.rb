# -*- encoding : utf-8 -*-

class CorrectVoteCountType < Card::Migration
  def up
    sql = "UPDATE cards c SET type_id = '#{Card::NumberID}' "\
          "WHERE (c.right_id = '#{Card['*vote count'].id}' "\
          "AND c.type_id = '#{Card::BasicID}') "\
          "AND c.trash is false;"
    ActiveRecord::Base.connection.execute(sql)
    Card::Cache.reset_all
  end
end
