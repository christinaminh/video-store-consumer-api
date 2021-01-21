class Video < ApplicationRecord
  has_many :rentals
  has_many :customers, through: :rentals

  validates_presence_of :title, :external_id
  validates_uniqueness_of :external_id, message: "Video is already in the video library."
  validate :from_database, on: :create
  validates :inventory, presence: true, numericality: { greater_than_or_equal_to: 0 }

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

  def from_database
    if self.title
      matching_videos_from_DB = VideoWrapper.search(self.title).find { |video| video[:external_id] == self.external_id && video[:title] == self.title }

      if matching_videos_from_DB.nil?
        errors.add(:external_id, "not found in video database")
      end
    end
  end
end
