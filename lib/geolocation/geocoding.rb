# frozen_string_literal: true

# Returns a Geocoder::Result object containing address, postal_code,
# latitude, longitude.
# Raise a NotFoundError if no location is found.
module Geolocation
  class Geocoding
    def self.search(address)
      result = Geocoder.search(address).first
      raise NotFoundError, 'No location found' if result.blank?

      result
    end
  end
end