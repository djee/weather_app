# frozen_string_literal: true

class WeatherController < ApplicationController
  def index
    @address = params[:address] || '1 Infinite Loop, Cupertino, California'
    geocode = Geolocation::Geocoding.search(@address.squish)

    cache_key = "#{geocode.postal_code || geocode.place_id}"
    @cached = Rails.cache.exist?(cache_key)
    @weather = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      Weather::Conditions.current(geocode.latitude, geocode.longitude)
    end
  rescue Geolocation::NotFoundError, Weather::ServiceError => e
    Rails.logger.error "Exception: #{e.class} - #{e.message}"
    flash.now[:error] = e.message
  end
end
