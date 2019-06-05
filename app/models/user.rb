class User < ApplicationRecord

  mount_uploader :avatar, AvatarUploader

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

 	validates :name, presence: true
 	validates :last_name, presence: true
  validates_integrity_of :avatar
  validates_processing_of :avatar
  validate :avatar_size

  has_many :subscriptions, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :assets, dependent: :destroy

  def free_subscription
    subscriptions.where(type: "FreeSubscription").first
  end

  def paid_subscription
    subscriptions.where(type: "PaidSubscription").last
  end

  def current_subscription
    subscriptions.where(status: "active").last
  end

  def current_plan?(plan_id)
    current_subscription.plan.id == plan_id
  end

  def full_name
    "#{name} #{last_name}"
  end

  def payment_method?
    card_last4.present?
  end

  def available_storage_space
    total_storage_space - used_storage_space
  end

  def used_storage_space
    total_file_size = 0
    self.assets.each do |asset|
      total_file_size += asset.uploaded_file.byte_size
    end
    total_file_size
  end

  def total_storage_space
    current_subscription.plan.space_allowed.gigabyte
  end

  def after_confirmation
    self.subscriptions.create!(plan: Plan.free_plan.first, status: 0,
        type: 'FreeSubscription')
  end

  private
    def avatar_size
      if avatar.size > 5.megabytes
        errors.add(:avatar, "should be less than 5MB")
      end
    end

end
