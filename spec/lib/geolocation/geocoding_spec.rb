# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Geolocation::Geocoding, type: :lib do
  describe ".search" do
    context 'with 200 success response' do
      before do
        # Stubbing Geocoder so we don't call the API during our test run
        Geocoder::Lookup::Test.set_default_stub(
          [
            {
              'coordinates'  => [37.3317, -122.0301],
              'address'      => '1 Infinite Loop, Cupertino, California',
              'state'        => 'California',
              'state_code'   => 'CA',
              'country'      => 'United States',
              'country_code' => 'US',
              'postal_code'  => '95014'
            }
          ]
        )
      end

      subject { described_class.search('1 Infinite Loop, Cupertino, California') }

      it 'return a Geocoder instance' do
        geocode = subject
        expect(geocode).not_to be_nil
        expect(geocode).to be_instance_of(Geocoder::Result::Nominatim)
      end
    end

    context 'with an error response' do
      before do
        allow_any_instance_of(Faraday::Connection)
          .to receive(:get)
          .and_raise(Faraday::ClientError.new(body: 'No latitude, Longitude parameter provided'))
      end

      it 'raise an NotFoundError' do
        expect { described_class.search('') }.to raise_exception(Geolocation::NotFoundError, 'No location found')
        expect { described_class.search('4 Imaginary World, Earth, Universe') }.to raise_exception(Geolocation::NotFoundError, 'No location found')
      end
    end
  end
end
