# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
unit1 = Unit.create(name: '中国邮政集团公司上海市分公司', desc: '中国邮政集团公司上海市分公司', no: '0001', short_name: 'sgs')

superadmin = User.create(email: 'superadmin@examples.com', username: 'superadmin', password: 'sgs12345', name: 'superadmin', role: 'superadmin', unit_id: 0)

role_1 = Role.create(user: superadmin, unit: unit1, role: 'superadmin')
unit2 = Unit.where(no: '9999').first_or_create(name: '处理中心', desc: '处理中心', no: '9999', short_name: 'clzx', pkp: 'GT')
user = User.where(username: 'gtadmin').first_or_create(username: 'gtadmin', password: 'gtadmin12345', name: '管理员', role: 'unitadmin', unit_id: unit2.id)
Role.where(user_id: user.id, unit_id: unit2.id).first_or_create(user_id: user.id, unit_id: unit2.id, role: "admin")

business = Business.where(no: '010103').first_or_create(name: "高铁", unit_id: unit2.id, no: "010103")