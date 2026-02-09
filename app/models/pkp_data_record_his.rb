class PkpDataRecordHis < ActiveRecord::Base
  self.abstract_class = true
  establish_connection("pkp_data_source_his_#{Rails.env}".to_sym)
end