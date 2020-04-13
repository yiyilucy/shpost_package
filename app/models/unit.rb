class Unit < ActiveRecord::Base
  has_many :users, dependent: :destroy
  
  validates_presence_of :name, :short_name, :message => '不能为空'
  validates_uniqueness_of :name, :message => '该单位已存在'

  validates_uniqueness_of :short_name, :message => '该缩写已存在'

  def can_pkp?
    if I18n.t("PkpWaybillBase.#{pkp}").include?"translation missing"
      return false
    else
      return true
    end
  end
  
  def pkp_businesses
    businesses = []

    if !I18n.t("PkpWaybillBase.#{pkp}").include?"translation missing"
      I18n.t("PkpWaybillBase.#{pkp}.businesses").each do |x|
        businesses << [Business.find_by(no: x[:business_no]).name, Business.find_by(no: x[:business_no]).id]
      end
    end
    return businesses
  end
end
