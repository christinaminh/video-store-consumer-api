class Video < ApplicationRecord
  has_many :rentals
  has_many :customers, through: :rentals

  validates_presence_of :title, :external_id
  validates_uniqueness_of :external_id, message: "Video is already in the video library."

  def available_inventory
    self.inventory - self.rentals.where(returned: false).length
  end

  def image_url
    raw_value = read_attribute :image_url
    if !raw_value
      VideoWrapper::DEFAULT_IMG_URL
    elsif /^https?:\/\//.match?(raw_value)
      raw_value
    else
      VideoWrapper.construct_image_url(raw_value)
    end
  end
end
