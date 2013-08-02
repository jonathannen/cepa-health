# encoding: utf-8
# Copyright © 2013 Jon Williams. See LICENSE.txt for details.

if defined?(Delayed)

  CepaHealth.register "Delayed Job", "warn" do
    now = Time.now.utc
    record "Delayed Job Backlog", true, Delayed::Job.count

    # Detect if the DJ backend is ActiveRecord or Mongoid Based
    query = case 
    when Delayed::Job.respond_to?(:order_by) then Delayed::Job.order_by(:run_at.desc)
    when Delayed::Job.respond_to?(:order) then Delayed::Job.order("run_at DESC")
    else nil
    end

    if query.nil?
      record "Unknown Delayed Job Backend", false, "#{Delayed::Job}"
    else
      # Maximum Delayed Job age is 10 minutes
      value = query.last
      if value.nil? || value.run_at > now
        record 'Delayed Job Backlog Age', true, 'No expired jobs'
      else
        diff = (now - value.run_at)
        record 'Delayed Job Backlog Age', diff < 600, "#{'%.1f' % (diff/60)} mins"
      end
    end

    true
  end  

end
