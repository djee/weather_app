# frozen_string_literal: true

# require_relative 'error/not_found_error'

module Geolocation
  class Geocoding
    def self.search(address)
      result = Geocoder.search(address).first
      raise NotFoundError, 'No location found' if result.blank?

      result
    end
  end
end