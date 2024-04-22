# frozen_string_literal: true

module Weather
  class Base
    attr_reader :latitude, :longitude, :units

    def initialize(lat, long, units = 'metric')
      @latitude = lat
      @longitude = long
      @units = units
    end

    def fetch(endpoint)
      connection.get("/data/2.5/#{endpoint}",
        appid: Rails.application.credentials.open_weather_map[:key],
        units: units,
        lat: latitude,
        lon: longitude,
        
      )
    rescue Faraday::ClientError, Faraday::ServerError => e
      raise ServiceError, e.response_body
    end

    private

    def connection
      @connection ||= Faraday.new(url: 'https://api.openweathermap.org/data/2.5', headers: { 'User-Agent' => 'jfdumas-dev-test' }) do |c|
        c.response :json
        c.response :raise_error
        c.response :logger, Rails.logger, log_level: :info do |formatter|
          formatter.filter(/(appid=\s*)\w+/i, '\1[FILTERED]')
        end
      end
    end
  end
end
