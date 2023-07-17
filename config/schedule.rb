# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :environment , :development
env :PATH, ENV['PATH']
env :GEM_PATH, ENV['GEM_PATH']

set :output, "log/cron_log.log"

every 2.minutes do
  runner "InterfaceSender.schedule_send"
end

every :day, :at => '0:15am' do
  runner "JdptInterface.batch_init_jdpt_trace"
end

every 2.minutes do
  runner "ImportFile.import_data"
end

every :day, :at => '11:35pm' do
  runner "JdptInterface.clean_data_by_days"
end

every 1.hours do  
  runner "YwtbInterface.batch_init_ywtb"
end

every 4.minutes do
	runner "PkpWaybillBase.get_pkp_waybill_bases_by_query_results_today"
end

every :day, :at => '0:02am' do
  runner "PkpWaybillBase.get_query_records_schedule"
end

every :day, :at => '6:00am' do
  runner "QueryResult.yl_export_results_yesterday"
end
