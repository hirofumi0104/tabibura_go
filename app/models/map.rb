class Map < ApplicationRecord
  belongs_to :post
  geocoded_by :address
end
