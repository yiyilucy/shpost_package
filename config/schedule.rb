# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#

env :PATH, ENV['PATH']
env :GEM_PATH, ENV['GEM_PATH']

set :output, "log/cron_log.log"

every 2.minutes do
  runner "InterfaceSender.schedule_send"
end

every '15 1 * * *' do  
  runner "JdptInterface.batch_init_jdpt_trace"
end

