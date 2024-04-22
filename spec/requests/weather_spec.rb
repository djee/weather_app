# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Weathers", type: :request do
  describe "GET /" do
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

    context 'with a valid address' do
      before do
        # Simply for testing Rails cache
        allow(Rails).to receive(:cache).and_return(memory_store)
        Rails.cache.clear

        # Stubbing Geocoder so we don't call the API during our test run
        Geocoder::Lookup::Test.set_default_stub(
          [
            {
              'coordinates'  => [37.3317, -122.0301],
              'address'      => '1 Infinite Loop, Cupertino, California',
              'city'         => 'Cupertino',
              'state'        => 'California',
              'state_code'   => 'CA',
              'country'      => 'United States',
              'country_code' => 'US',
              'postal_code'  => '95014'
            }
          ]
        )

        # Prevents an external call to the Weather API and provide a controlled response
        allow_any_instance_of(Faraday::Connection)
          .to receive(:get)
          .and_return(double('response', status: 200, body: JSON.parse(load_fixture('weather', 'conditions'))))
      end

      it "returns http success" do
        get "/"
        expect(response).to have_http_status(:success)
      end

      it 'returns the conditions for default address' do
        get "/"
        expect(response.body).to include("Cupertino")
      end

      it 'returns the conditions for the passed in address' do
        # Stubbing Geocoder to a defined address
        Geocoder::Lookup::Test.add_stub(
          "160 Castro St, Mountain View, California, 94041", [
            {
              'coordinates'  => [37.3943827, -122.078829],
              'address'      => '160 Castro St, Mountain View, California, 94041',
              'city'         => 'Mountain View',
              'state'        => 'California',
              'state_code'   => 'CA',
              'country'      => 'United States',
              'country_code' => 'US',
              'postal_code'  => '94041'
            }
          ]
        )

        get "/", params: { address: '160 Castro St, Mountain View, California, 94041' }
        expect(response.body).to include("Mountain View")
      end

      it 'cache the weather api response using place_id since no zipcode exists' do
        # Stubbing Geocoder to a defined address
        Geocoder::Lookup::Test.add_stub(
          "Cupertino, California", [
            {
              'place_id'     => 311498343,
              'coordinates'  => [37.3688301, -122.036349],
              'address'      => 'Sunnyvale, California',
              'city'         => 'Sunnyvale',
              'state'        => 'California',
              'state_code'   => 'CA',
              'country'      => 'United States',
              'country_code' => 'US',
            }
          ]
        )

        expect(Rails.cache.exist?('311498343')).to be_falsy
        get "/", params: { address: 'Sunnyvale, California' }
        expect(Rails.cache.exist?('311498343')).to be_truthy
      end

      # This will use the default 
      it 'cache the weather map api response using zipcode' do
        expect(Rails.cache.exist?('95014')).to be_falsy
        get "/"
        expect(Rails.cache.exist?('95014')).to be_truthy
      end
    end
  end
end
