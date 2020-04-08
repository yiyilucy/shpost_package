class PkpWaybillBase < PkpDataRecord
  def self.get_query_records_schedule
    start_date = Date.today - 2.day
    end_date = Date.today - 1.day
    get_query_records(start_date, end_date)
  end
  
  def self.get_query_records(start_date, end_date)
    businesses = I18n.t(:YwtbInterface)[:businesses]
    businesses.each do |x|
      if x[:need_data_from_pkp]
        business_no = x[:business_no]
        business = Business.find_by no: business_no

        if !business.blank?
          sender_no = x[:sender_no]
          
          pkp_waybill_bases = self.where(sender_no: sender_no).where("biz_occur_date >= '#{start_date}' and biz_occur_date < '#{end_date}'")
          ActiveRecord::Base.transaction do
            pkp_waybill_bases.each do |x|
              query_result = QueryResult.find_or_initialize_by(registration_no: x.waybill_no, business: business)

              query_result.business = business
              query_result.unit = business.unit

              query_result.registration_no = x.waybill_no
              query_result.status = QueryResult::STATUS[:waiting]
              query_result.source = 'ESB'
              query_result.business_code = x.logistics_order_no if query_result.business_code.blank?
              
              query_result.postcode = x.sender_postcode
              query_result.order_date = x.biz_occur_date.to_date

              query_result.is_posting = false
              query_result.is_sent = false
              query_result.to_send = true

              if query_result.qr_attr.blank?
                query_result.qr_attr = QrAttr.new
              end
              qr_attr = query_result.qr_attr
              qr_attr.name = x.receiver_linker
              qr_attr.address = x.receiver_addr
              qr_attr.province = x.receiver_province_name
              qr_attr.city = x.receiver_city_name
              qr_attr.district = x.receiver_county_name
              qr_attr.phone = x.receiver_mobile || x.receiver_fixtel
              qr_attr.batch_date = x.biz_occur_date
              qr_attr.save!
              query_result.save!
            end
          end
        end
      end
    end
  end

  #4 common
  def self.get_pkp_waybill_bases_yesterday(name)
    businesses = I18n.t(:PkpWaybillBase)[name.to_sym][:businesses]
    businesses.each do |x|
      business_no = x[:business_no]
      business = Business.find_by no: business_no

      if !business.blank?
        sender_no = x[:sender_no]
        
        pkp_waybill_bases = self.where(sender_no: sender_no).where(created_day: Date.yesterday.strftime("%d")).where("biz_occur_date >= ? ",Date.yesterday).where("biz_occur_date < ? ", Date.today)

        ActiveRecord::Base.transaction do
          pkp_waybill_bases.each do |x|
            next if QueryResult.exists?(["registration_no = ? and business_id != ?", x.waybill_no, business.id]) #Maybe delete if change registration_no uniq to registration_no&business uniq

            query_result = QueryResult.find_or_initialize_by(registration_no: x.waybill_no, business: business)

            query_result.update!(registration_no: x.waybill_no, business: business, unit: business.unit, status: QueryResult::STATUS[:waiting], source: 'ESB', business_code: x.logistics_order_no, postcode: x.sender_postcode, order_date: x.biz_occur_date, is_posting: false, is_sent: false, to_send: false)


            pkp_waybill_base_local = query_result.pkp_waybill_base_local

            pkp_waybill_base_local ||= PkpWaybillBaseLocal.new(query_result: query_result)

            pkp_waybill_base_local = x.to_local pkp_waybill_base_local

            pkp_waybill_base_local.save!
          end
        end
      end
    end
  end

  def to_local(pkp_waybill_base_local = nil)
    #copy pkp_waybill_base
    pkp_waybill_base_local ||= PkpWaybillBaseLocal.new
    
    PkpWaybillBase.columns.each{|c| pkp_waybill_base_local[c.name] = x[c.name] if pkp_waybill_base_local.response_to("#{c.name}=") && ! c.name.in?(["id", "created_at", "updated_at"]) }

    return pkp_waybill_base_local
  end
end
