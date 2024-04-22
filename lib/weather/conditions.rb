# frozen_string_literal: true

# Returns the current weather conditions as an OpenStruct object for the provided latitude and longitude
module Weather
  class Conditions < Base
    # Setting units to imperial by default since its most commonly use in the US.
    # For the list of data type consult https://openweathermap.org/weather-data
    # No support for 'standard' units is provided within this code.
    def self.current(lat, long, units='imperial')
      response = new(lat, long, units).fetch('weather')

      weather = OpenStruct.new
      weather.units = units == 'imperial' ? 'F' : 'C'
      weather.name = response.body['name']
      weather.temp = response.body['main']['temp'].round
      weather.feels_like = response.body['main']['feels_like'].round
      weather.temp_min = response.body['main']['temp_min'].round
      weather.temp_max = response.body['main']['temp_max'].round
      weather.humidity = response.body['main']['humidity']
      weather.pressure = response.body['main']['pressure']
      weather.description = response.body['weather'].first['description']
      weather.icon = response.body['weather'].first['icon']
      weather
    end
  end
end
