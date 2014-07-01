# encoding: utf-8
# Copyright © 2013 Jon Williams. See LICENSE.txt for details.

if defined?(Delayed)

  CepaHealth.register :warn do
    priority = ENV['MAX_PRIORITY'] || 10
    now = Time.now.utc
    record "Delayed Job Backlog", true, Delayed::Job.count

    # Detect if the DJ backend is ActiveRecord or Mongoid Based
    type = case
    when Delayed::Job.respond_to?(:order_by) then :mongoid
    when Delayed::Job.respond_to?(:order) then :active_record
    else nil
    end

    # Maximum Delayed Job age is an hour
    unless type.nil?
      query = type == :active_record ? Delayed::Job.order("run_at DESC") : Delayed::Job.order_by(:run_at.desc)
      value = query.last
      if value.nil? || value.run_at > now
        record 'Delayed Job Backlog Age', true, 'No expired jobs'
      else
        diff = (now - value.run_at)
        record 'Delayed Job Backlog Age', diff < 3600, "#{'%.1f' % (diff/60)} mins"
      end
    end

    # Check for failed jobs
    if type.nil?
      [ "Unknown Delayed Job Backend", false, "#{Delayed::Job}" ]
    else
      failures = if type == :active_record 
        Delayed::Job.where("attempts > 0 AND priority < #{priority}").count 
      else
        Delayed::Job.where(:attempts.gt => 0, :priority.lt => priority).count
      end
      ["Delayed Job Failures", failures == 0, "#{failures} failed job#{failures == 1 ? '' : 's'}"]
    end
  end

end
