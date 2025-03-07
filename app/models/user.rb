class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  belongs_to :unit
  has_many :user_logs
  has_many :roles, dependent: :destroy

  devise :database_authenticatable, #:registerable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable, :lockable

  validates_presence_of :username, :name, :unit_id, :role, :message => '不能为空字符'#,

  validates_uniqueness_of :username, :message => '该用户已存在'

  validate :password_complexity

  ROLE = { superadmin: '超级管理员', unitadmin: '机构管理员', user: '用户' }

  def rolename
    User::ROLE[role.to_sym]
  end

  def superadmin?
    (role.eql? 'superadmin') ? true : false
  end

  def unitadmin?
    (role.eql? 'unitadmin') ? true : false
  end

  def user?
    (role.eql? 'user') ? true : false
  end

  def email_required?
    false
  end

  def password_required?
    encrypted_password.blank? ? true : false
  end

  def password_complexity
    if password.present?
       if !password.match(/^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,128}$/) 
         errors.add :password, "密码需同时包含英文字母和数字"
       end
    end
  end

end
