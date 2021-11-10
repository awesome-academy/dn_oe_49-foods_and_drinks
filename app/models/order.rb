class Order < ApplicationRecord
  belongs_to :user
  has_many :order_details, dependent: :destroy
  has_many :products, through: :order_details

  delegate :name, to: :address, prefix: true
  delegate :name, :email, to: :user, prefix: true
  enum status: {
    open: Settings.open,
    confirmed: Settings.confirmed,
    shipping: Settings.shipping,
    completed: Settings.completed,
    cancelled: Settings.cancelled,
    disclaim: Settings.disclaim
  }
  scope :recent_orders, ->{order created_at: :desc}

  validates :name, :phone, :address, presence: true,
    length: {maximum: Settings.length.max_250}
  validates :total_price, presence: true,
    numericality:
    {
      only_integer: false,
      greater_than_or_equal_to: Settings.init_number
    }
end
