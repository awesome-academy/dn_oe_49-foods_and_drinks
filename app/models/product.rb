class Product < ApplicationRecord
  belongs_to :category
  has_many :order_details, dependent: :destroy
  has_many :orders, through: :order_details
  has_one_attached :thumbnail
  has_many_attached :images

  accepts_nested_attributes_for :category, allow_destroy: true,
                                           reject_if: :validate_nested

  scope :find_name, ->(name){where "name LIKE ?", "%#{name}%" if name.present?}
  scope :recent_products, ->{order created_at: :desc}
  scope :find_products_cart, ->(pr_id){where id: pr_id}
  scope :filter_category, (lambda do |category_id|
    where(category_id: category_id) if category_id.present?
  end)

  enum status: {disabled: 0, enabled: 1}

  delegate :name, to: :category, prefix: true

  validates :name, presence: true,
    length: {
      minimum: Settings.length.min_5,
      maximum: Settings.length.max_250
    }

  validates :price, presence: true,
                    numericality:
                    {
                      only_integer: false,
                      greater_than_or_equal_to: Settings.init_number
                    }

  validates :description, presence: true,
    length: {
      minimum: Settings.length.min_5,
      maximum: Settings.length.max_250
    }

  validates :quantity, presence: true,
                       numericality:
                       {
                         only_integer: true,
                         greater_than_or_equal_to: Settings.init_number
                       }

  validates :images,
            content_type:
            {
              in: Settings.image.format,
              message: I18n.t("validate_image.msg_format")
            },
            size:
            {
              less_than: Settings.image.size_5mb.megabytes,
              message: I18n.t("validate_image.msg_size")
            }

  validates :thumbnail,
            content_type:
            {
              in: Settings.image.format,
              message: I18n.t("validate_image.msg_format")
            },
            size:
            {
              less_than: Settings.image.size_5mb.megabytes,
              message: I18n.t("validate_image.msg_size")
            }

  def display_image input
    images[input].variant(resize: Settings.resize_images).processed
  end

  def display_thumbnail
    thumbnail.variant(resize: Settings.resize_thumbnail).processed
  end

  def self.handle_check spreadsheet, header, arr
    (Settings.row_2..spreadsheet.last_row).each do |i|
      row = [header, spreadsheet.row(i)].transpose.to_h
      begin
        check_create row, arr, i
      rescue ActiveRecord::RecordInvalid => e
        arr.push(I18n.t("validate_excel.row") + "#{i}  #{e.message}")
      end
      return arr if i == spreadsheet.last_row
    end
  end

  def validate_nested attribute
    return true if attribute[:name].blank?

    dem = 0
    Category.pluck(:name, :description).each do |item|
      next unless attribute[:name] == item[0] &&
                  attribute[:description] == item[1]

      dem = 1
      break
    end
    dem != 0
  end

  class << self
    private

    def check_create row, arr, index
      if check_status? row["status"]
        arr.push(index) unless Product.create! row
      else
        arr.push(I18n.t("validate_excel.row") + index.to_s +
                 I18n.t("validate_excel.check_status"))
      end
    end

    def check_status? status
      Product.statuses.include?(status) ||
        Product.statuses.values.include?(status)
    end
  end
end
