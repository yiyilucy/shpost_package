class CreatePkpWaybillBases < ActiveRecord::Migration
  def change
      create_table :pkp_waybill_bases do |t|
        t.integer :pkp_waybill_id #运单流水号
        t.integer :order_id #订单号（平台唯一）
        t.string :logistics_order_no
        t.string :inner_channel #0:直接对接 1：邮务国内小包订单系统 2：邮务国际小包订单系统 3：速递国内订单系统 4：速递国际订单系统5：在线发货平台 6、11183派揽调度
        t.integer  :base_product_id #基础产品编号
        t.string :base_product_no #基础产品代码
        t.string :base_product_name #基础产品名称
        t.integer :biz_product_id #业务产品编号
        t.string :biz_product_no #业务产品代码
        t.string :biz_product_name #业务产品名称
        t.string :product_type
        t.string :product_reach_area #寄达范围 1：同城 2：地市 3：省内 4：国内 5：国际(地区)
        t.string :contents_attribute #内件性质 1：文件 2：信函 3：物品 4：包裹 
        t.string :cmd_code
        t.string :manual_charge_reason
        t.string :time_limit #寄达时限 1：当日递 2：次晨达 3：次日递 4：限时递 5：当日上午递 6：经济时限 9：标准时限  
        t.string :io_type #收寄来源：10：录入收寄  20：导入收寄 30：PDA收寄 40：终端收寄
        t.string :ecommerce_no #电商标识
        t.string :waybill_type #单据类型: 0常规运单 1退件运单
        t.string :waybill_no #运单号
        t.string :pre_waybill_no #标识 上游客户的单据号，或者返单业务对应的正向邮件号
        t.string :biz_occur_date #业务发生时间（分表），预告信息接入代表接入时间，PDA揽收代表揽收时间，收寄作业代表收寄时间，运单调整代表申请调整时间。
        t.datetime :biz_occur_date #业务发生时间（分表），预告信息接入代表接入时间，PDA揽收代表揽收时间，收寄作业代表收寄时间，运单调整代表申请调整时间。
        t.integer :post_org_id #收寄机构编号
        t.string :post_org_no #收寄机构代码
        t.string :org_drds_code #分库机构代码（分库）
        t.string :post_org_name #收寄机构名称
        t.integer :post_person_id	#收寄人员编号
        t.string :post_person_no	#收寄人员代码
        t.string :post_person_name	#收寄人员名称
        t.string :post_person_mobile	#收寄人员电话
        t.string :sender_type	#寄件客户类型：0 散户 1协议客户
        t.integer :sender_id	#寄件客户编号
        t.string :sender_no	#寄件客户代码(大宗客户代码)
        t.string :sender	#寄件客户名称
        t.integer :sender_warehouse_id	#寄件客户分仓编号
        t.string :sender_warehouse_name	#寄件客户分仓名称
        t.string :sender_linker	#寄件联系人
        t.string :sender_fixtel	#寄件客户电话
        t.string :sender_mobile	#寄件客户手机
        t.string :sender_im_type	#寄件即时通讯类型 1：微信  2：QQ  3:淘宝旺旺
        t.string :sender_im_id	#寄件即时通讯ID
        t.string :sender_id_type	#寄件人证件类型 1:居民身份证、临时居民身份证、临时或者户口簿 2:中国人民解放军身份证件、中国人民武装警察身份证件 3:港澳居民来往内地通行证、台湾居民来往内地通行证或者其他有效旅行证件 4:外国公民护照 5:法律、行政和国家规定的其他有效身份证件
        t.string :sender_id_no	#寄件人证件号码
        t.string :sender_id_encrypted_code	#寄件人身份信息伪码  
        t.string :sender_agent_id_type	#交寄人证件类型 1:居民身份证、临时居民身份证、临时或者户口簿 2:中国人民解放军身份证件、中国人民武装警察身份证件 3:港澳居民来往内地通行证、台湾居民来往内地通行证或者其他有效旅行证件 4:外国公民护照 5:法律、行政和国家规定的其他有效身份证件
        t.string :sender_agent_id_no	#交寄人证件号码
        t.string :sender_id_encrypted_code_agent	#交寄人身份信息伪码
        t.string :sender_addr	#寄件客户地址
        t.string :sender_addr_additional	#外文收寄地址
        t.string :sender_country_no	#寄件国家代码
        t.string :sender_country_name	#寄件国家名称
        t.string :sender_province_no	#寄件省份代码
        t.string :sender_province_name	#寄件省份名称
        t.string :sender_city_no	#寄件城市代码
        t.string :sender_city_name	#寄件城市名称
        t.string :sender_county_no	#寄件区县代码
        t.string :sender_county_name	#寄件区县名称
        t.string :sender_district_no	#寄件行政区划
        t.string :sender_postcode	#寄件邮编
        t.string :sender_gis	#寄件GIS坐标
        t.string :sender_notes	#寄件备注
        t.string :registered_customer_no	#注册客户号
        t.string :receiver_type	#收件客户类型：0 散户 1协议客户
        t.integer :receiver_id	#收件客户编号
        t.string :receiver_no	#收件客户代码（大宗客户代码）
        t.string :receiver	#收件客户名称收件人名称？
        t.integer :receiver_warehouse_id	#收件客户分仓编号
        t.string :receiver_warehouse_name	#收件客户分仓名称
        t.string :receiver_linker	#收件联系人收件人名称？
        t.string :receiver_im_type	#收件即时通讯类型 1：微信  2：QQ  3:淘宝旺旺
        t.string :receiver_im_id	#收件即时通讯ID
        t.string :receiver_fixtel	#收件客户电话
        t.string :receiver_mobile	#收件客户手机
        t.string :receiver_addr	#收件客户地址        
        t.string :receiver_addr_additional	#收件客户附加地址
        t.string :receiver_country_no	#收件国家代码
        t.string :receiver_country_name	#收件国家名称
        t.string :receiver_province_no	#收件省份代码
        t.string :receiver_province_name	#收件省份名称
        t.string :receiver_city_no	#收件城市代码
        t.string :receiver_city_name	#收件城市名称
        t.string :receiver_county_no	#收件区县代码
        t.string :receiver_county_name	#收件区县名称
        t.string :receiver_district_no	#收件行政区划
        t.string :receiver_postcode	#收件邮编
        t.string :receiver_gis	#收件GIS坐标
        t.string :receiver_notes	#收件备注
        t.integer :customer_manager_id	#客户经理编号
        t.string :customer_manager_no	#客户经理代码
        t.string :customer_manager_name	#客户经理名称
        t.integer :salesman_id	#营销员编号
        t.string :salesman_no	#营销员代码
        t.string :salesman_name	#营销员名称
        t.decimal :order_weight	, :precision => 8, :scale => 0 #订单重量
        t.decimal :real_weight	, :precision => 8, :scale => 0 #实际重量
        t.decimal :fee_weight	, :precision => 8, :scale => 0 #计费重量
        t.decimal :volume_weight, :precision => 8, :scale => 0 #体积重
        t.decimal :volume	, :precision => 8, :scale => 0 #体积
        t.decimal :length	, :precision => 8, :scale => 0 #长
        t.decimal :width	, :precision => 8, :scale => 0 #宽
        t.decimal :height	, :precision => 8, :scale => 0 #高
        t.integer :quantity	#数量
        t.string :packaging	#邮件包装
        t.string :package_material	#包装材质
        t.string :goods_desc	#货物描述
        t.string :contents_type_no	#内件类型代码
        t.string :contents_type_name	#内件类型名称
        t.decimal :contents_weight  , :precision => 8, :scale => 0#内件商品重量
        t.integer :contents_quantity	#内件商品数量
        t.string :cod_flag	#代收款标志（附加服务）：1:代收货款 2:代缴费 9:无
        t.decimal :cod_amount  , :precision => 12, :scale => 2#代收款金额
        t.string :receipt_flag	#回单标志（反馈方式） 1:基本 2:回执 3:短信 5:电子返单 6:格式返单 7:自备返单 8:反向返单  
        t.string :receipt_waybill_no	#回单运单号
        t.decimal :receipt_fee_amount  , :precision => 12, :scale => 2#回单费金额
        t.string :insurance_flag	#保价保险标志（所负责任）1:基本 2:保价 3:保险 
        t.decimal :insurance_amount  , :precision => 12, :scale => 2#保价保险金额
        t.decimal :insurance_premium_amount  , :precision => 12, :scale => 2#保费金额
        t.string :valuable_flag	#贵品标识
        t.string :transfer_type	#运输方式
        t.string :pickup_type	#揽收方式 1：客户送货上门    2：机构上门揽收
        t.string :allow_fee_flag	#是否可计费标志：0不可计费 1可计费
        t.string :is_feed_flag	#计费完成标志：0 未计费 1已计费
        t.datetime :fee_date	#计费时间
        t.decimal :postage_total  , :precision => 12, :scale => 2#总资费=实收邮资+其他资费
        t.decimal :postage_standard  , :precision => 12, :scale => 2#标准邮资
        t.decimal :postage_paid  , :precision => 12, :scale => 2#实收邮资
        t.decimal :postage_other  , :precision => 12, :scale => 2#其它资费
        t.string :payment_mode	#付款方式(付费方) 1:寄件人 2:收件人 3:第三方 4:收件人集中付费 5:免费 6:寄/收件人 7:预付卡 
        t.decimal :discount_rate , :precision => 6, :scale => 2#优惠率 单位%
        t.string :settlement_mode	#结算方式 1:现结 2:计欠 3:预付费 
        t.string :payment_state	#支付状态 0未支付 1已支付
        t.datetime :payment_date	#支付时间
        t.string :payment_id	#支付流水号
        t.string :is_advance_flag	#是否预告标志 0：无预告  1：有预告 
        t.string :deliver_type	#投递方式要求 1:上门投递 2:客户自提
        t.string :deliver_sign	#投递签收要求 10：验示身份证 20：本人签收并验示身份证 30：收款 40：验示内件 50：验证取货码 60：拍照 70：电话预约 80：收回返单
        t.string :deliver_date	#投递时间要求 0:无限制 1:工作日 2:双休日 
        t.string :deliver_notes	#投递要求备注
        t.datetime :deliver_pre_date	#预约投递时间
        t.string :battery_flag	#有无电池标志：0 无 1有
        t.string :workbench	#台席
        t.string :electronic_preferential_no	#电子优惠券号
        t.decimal :electronic_preferential_amount  , :precision => 12, :scale => 2#电子优惠券金额
        t.string :pickup_attribute	#收寄属性 1：全部  2：邮政 3：速递
        t.string :adjust_type	#调整信息类型：10 收寄查改 20  撤单 30 改址 40 删除
        t.decimal :postage_revoke  , :precision => 12, :scale => 2#撤单费用
        t.string :print_flag	#打印标志 0：未打印 1：已打印
        t.datetime :print_date	#打印时间
        t.integer :print_times	#打印次数
        t.string :is_deleted	#是否删除：0：否1：是
        t.integer :create_user_id	#创建人id
        t.datetime :gmt_created	#创建时间
        t.integer :modify_user_id	#修改人id
        t.datetime :gmt_modified	#修改时间
        t.string :declare_source	#申报信息来源,1:个人申报；2:企业申报；3:个人税款复核
        t.string :declare_type	#申报类别
        t.string :declare_curr_code	#申报币制代码
        t.string :reserved1	#预留字段1
        t.string :reserved2	#预留字段2
        t.string :reserved3	#预留字段3
        t.string :reserved4	#预留字段4
        t.string :reserved5	#预留字段5
        t.string :reserved6	#预留字段6
        t.string :reserved7	#预留字段7
        t.string :reserved8	#预留字段8
        t.datetime :reserved9	#预留字段9
        t.text :reserved10	#预留字段10

        t.timestamps
      end
  end
end
