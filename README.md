# README

## Weather App

The weather app project allows to retrieve the weather for a specific address. It uses the (OpenWeatherMap API)[https://openweathermap.org] and the OpenStreetMap Geocoder API via the (Geocoder)[https://github.com/alexreisner/geocoder] gem to achieve this goal.

## Installing the project

Below are the different steps that I took to start the project.

### Installing Ruby

I used (rvm)[https://rvm.io] to work with the different ruby version.
Here is the command I use to install the version of ruby that is use in this project.
```bash
rvm install ruby-3.2.2
```

Note that, if ruby 3.2.2 is already installed on your machine, the `.ruby-version` will be picked up by most ruby version manager out there. 

### Installing Node

I used (nvm)[https://github.com/nvm-sh/nvm/blob/master/README.md] to work with the different node version.

Here is the command I use to install the LTS Node version
```bash
nvm install --lts
```

### Installing Rails

The project uses the most recent Rails version 7.1.3.2

gem install rails

I then created the project using this command and making sure that I was including bootstrap as the CSS framework and skipping minitest since this project will be using rspec.
```bash
rails new weather_app --css bootstrap --skip-test
```

Note that following this step I added a few gems to start building towards the weather app project:

* geocoder This gem helps retrieve the latitude and longitude values for a given address.
* faraday This library serves as an HTTP client for making API requests.
* rspec-rails (in the test group) This gem provides the RSpec testing framework for unit and integration tests.
* byebug (in the development, test group), This gem aids in debugging during development and testing by allowing you to set breakpoints and inspect variables.

After adding these gems, I ran bundle install to install them into the project.
```bash
bundle install
```

Finally, I started the Rails server using rails s to run the application locally.
```bash
rails s
```

### Setup rspec

I ran the rspec installer command that will basically generate the spec_helper and rails_helper
```bash
rails g rspec:install
```

I update the generator configuration in `config/application.rb` so rails will use rspec generator for creating test files

### Running the tests
I simply run this command and the test suite will run
```bash
RAILS_ENV=test rspec
```

### Create API key for OpenWeatherMap

Creating an API key for OpenWeatherMap is a straightforward process. Their free tier allows you to make up to 1 request per second on the API. To create an account and obtain an API key, visit https://openweathermap.org.

I saved this API key as the Rails credentials. I chose to create a credentials file specific to the development environment using this command:
```bash
rails credentials:edit --environment development
```

## Breakdown

### Weather Controller

This controller receives the address input that is passed from the user interface. I chose to only expose the index method of the controller.

The `WeatherController#index` method contains the logic that will fetch the coordinates (latitude, longitude) for the address inputted by a user. These coordinates are then passed to the weather API to retrieve the current conditions at the given location.

### Geolocation::Geocoding
The Geocoder logic is contained in the `Geolocation::Geocoding` class that lives in the `lib/geolocation/geocoding.rb`. Encapsulating this logic allows for cleaner code separation and remain easy to integrate within the application.  I did not believe that the code in this class qualify for a Service Object so it ended up in the lib folder.

Note that the Geocoder gem is using by default OpenStreetMap API. That API does not necessitate an API key but also does not support more than 1 request/second. This is not something that I will recommend using in a production environment. There is much better suited API out there that could be use with better limit of requests/second

`Geolocation::Geocoding` will raise a `Geolocation::NotFoundError` if the OpenStreetMap service is returning an empty response.

```ruby
geocode = Geolocation::Geocoding.search('1 Apple Park way, Cupertino, California')
```
From the return object, we retrieve the postal_code(zipcode), latitude, longitude value.

###  Weather::Conditions
The Weather API logic is encapsulate in a separate class inheriting from a class named Base. That class contains the http client (Faraday) logic to call the API. The `Weather::Conditions` class contains a static method to call the current weather conditions named `current`. It returns a OpenStruct object of the weather data. Like the `Geolocation::Geocoding` class, the `Weather::Conditions` class sits in the lib folder under the `lib/weather/conditions.rb`

`Weather::Conditions` will raise a `Weather::ServiceError` if the OpenWeatherMap service is returning an improper response. 

```ruby
Weather::Conditions.current(geocode.latitude, geocode.longitude)
```

In hindsight, I realized that I could have encapsulate both the `Geolocation::Geocoding` and `Weather::Conditions` in a Service Object that would have handle the logic of these 2 class together. That would have made a much cleaner and skinny controller. 

### Caching

The Geocoder gem offers caching capabilities when configured. I configured caching in `config/initializer/geocoder.rb`. to store results for 2 days. This caching helps reduce the number of API calls made to the OpenStreetMap service and improves the overall performance of the application.

Current weather conditions are cached based on the postal_code (zipcode) returned by the `Geolocation::Geocoding` class. Additionally, caching is applied using the place ID since searches for cities (without full addresses) might not return a postal code.

To enable cache functionality in a development environment, you can use the following command:
```bash
rails dev:cache
```

### Security

I used any other method than `squish` to *sanitize* the string that a user can input. This is far from ideal, I could use the sanitize gem to prevent XSS attack. While I did use sanitize within the html template to mitigate some XSS risk, it's important to sanitize the input data as well for better security.
