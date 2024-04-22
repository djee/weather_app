# README

## Weather App

The weather app project allow to retrieve the weather for a specific address. It use the (OpenWeatherMap API)[https://openweathermap.org] and the OpenStreetMap Geocoder API via the (Geocoder)[https://github.com/alexreisner/geocoder] gem to achieve this goal.

## Installing the project

Below are the different steps that I took to start the project. 

### Installing Ruby

I uses (rvm)[https://rvm.io] to work with the different ruby version.
Here is the command I use to install the version of ruby that is use in this project.
```bash
rvm install ruby-3.2.2
```

Note that, if ruby 3.2.2 is already installed on your machine, the `.ruby-version` will be picked up by most ruby version manager out there. 

### Installing Node

I uses (nvm)[https://github.com/nvm-sh/nvm/blob/master/README.md] to work with the different node version.

Here is the command I use to install the LTS Node version
```bash
nvm install --lts
```

### Installing Rails

The project use the most recent Rails version 7.1.3.2

gem install rails

I then created the project using this command and making sure that I was including bootstrap as the CSS framework and skipping minitest since this project will be using rspec.
```bash
rails new weather_app --css bootstrap --skip-test
```

Note that following this step I added a few gems to start building towards the weather app project:

* geocoder to retrieve the address latitude and longitude value. 
* faraday as an http client
* rspec-rails in the test group as a testing framework
* byebug in the development, test group, to help debug along the way

and then I ran: 
```bash
bundle install
```

and finally I start the rails server
```bash
rails s
```

### Setup rspec

I ran the rspec installer command that will basically genere the spec_helper and rails_helper
```bash
rails g rspec:install
```

I update the generator configuration in `config/application.rb` so rails will use rspec generator for creating test files

### Running the tests

```bash
RAILS_ENV=test rspec
```

### Create API key for OpenWeatherMap

Creating the API key for OpenWeatherMap is straightforward and free of uses if there is no more than 1 request a second on the API.
Go to https://openweathermap.org to create an account and the API key.

I saved this API key in the rails credentials.  I choose to create a credentials file by environment. 

```bash
rails credentials:edit --environment development
```

### Weather Controller

This controller is the receiver of the address input that is pass from the User Interface. I choose to only expose the index method of the controller.
The WeatherController#index contains the logic that will fetch the Geocoding for the address inputted by a user. The Geo coordinate of that address are then pass to the weather API to retrieve the current conditions at the given coordinate. 

**Geolocation::Geocoding**
The Geocoder logic is contained in the `Geolocation::Geocoding` class that lives in the `lib/geolocation/geocoding.rb`. Encapsulating this logic allow for cleaner code separation and remains easy to integrate within the application.  I did not believe that the code in this class qualify for a Service Object so it ended up in the lib folder.

Note that the Geocoder gem is using by default OpenStreetMap API. That API does not necessitate an API key but also does not support more than 1 request/second. This is by no mean something that I will recommend using in a production environment. There is much better suited API out there that could be use with better limit of requests/second

`Geolocation::Geocoding` will raise a `Geolocation::NotFoundError` if the OpenStreetMap service is returning an empty response.

```ruby
geocode = Geolocation::Geocoding.search('1 Apple Park way, Cupertino, California')
```
From the return object, we retrieve the postal_code(zipcode), latitude, longitude value.

**Weather::Conditions**
The Weather API logic is encapsulate in a separate class inheriting from a class named Base. That class contains the http client (Faraday) logic to call the API. The `Weather::Conditions` class contains a static method to call the current weather conditions named `current`. It returns a OpenStruct object of the weather data. Like the `Geolocation::Geocoding` class, the `Weather::Conditions` class sits in the lib folder under the `lib/weather/conditions.rb`

`Weather::Conditions` will raise a `Weather::ServiceError` if the OpenWeatherMap service is returning an improper response. 

```ruby
Weather::Conditions.current(geocode.latitude, geocode.longitude)
```

In hindsight, I realized that I could have encapsulate both the `Geolocation::Geocoding` and `Weather::Conditions` in a Service Object that would have handle the logic of these 2 class together. That would have made a much cleaner and skinny controller. 

### Security

I did use sanitize in the address input on the index page. I've didn't use any other method than `squish` to *clean* the string that a user can input.  I did use sanitize in the html template to make sure that an xss injection was not possible or at least to mitigate the most obvious vector of attack.

### Caching

The Geocoder gem offer cache out of the box if configured. I took the time to configure this in the `config/initializer/geocoder.rb`. I set it to be cache for 2 days.

The current weather conditions are cached based on the postal_code(zipcode) that the `Geolocation::Geocoding` class returns.  I also add a fallback on the place_id since if you search for a city instead of a full address, we will get a result without a postal_code.

To activate the cache in development
```bash
rails dev:cache
```

