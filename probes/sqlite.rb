# encoding: utf-8
# Copyright © 2013 Jon Williams. See LICENSE.txt for details.

if defined?(ActiveRecord) && defined?(SQLite3)

  CepaHealth.register "SQLite" do
    begin
      ActiveRecord::Base.connection.exec_query("PRAGMA quick_check")
      true
    rescue Exception => e
      record("SQLite Failure", false, e.inspect)
      false
    end
  end

end
