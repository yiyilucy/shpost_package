# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# unit1 = Unit.create(name: '中国邮政集团公司上海市分公司', desc: '中国邮政集团公司上海市分公司', no: '0001', short_name: 'sgs')

# superadmin = User.create(email: 'superadmin@examples.com', username: 'superadmin', password: 'sgs12345', name: 'superadmin', role: 'superadmin', unit_id: 0)

# role_1 = Role.create(user: superadmin, unit: unit1, role: 'superadmin')
# unit2 = Unit.where(no: '9999').first_or_create(name: '处理中心', desc: '处理中心', no: '9999', short_name: 'clzx', pkp: 'GT')
# user = User.where(username: 'gtadmin').first_or_create(username: 'gtadmin', password: 'gtadmin12345', name: '管理员', role: 'unitadmin', unit_id: unit2.id)
# Role.where(user_id: user.id, unit_id: unit2.id).first_or_create(user_id: user.id, unit_id: unit2.id, role: "admin")


unit = Unit.create(name: '运管部', desc: '运管部', no: '9998', short_name: 'ygb', pkp: 'YGB')

business = Business.create(name: '运管部', unit_id: unit.id, no: '010104')

user = User.create(username: "ygbadmin", role: "unitadmin", name: "管理员", unit_id: unit.id, password: 'ygbadmin12345')

unit_yl = Unit.create(name: '银联', desc: '银联', no: '10000', short_name: 'yl', pkp: 'YL')
business_yl = Business.create(name: '银联', start_date: 1, end_date:8, unit_id: unit_yl.id, no: '010105')