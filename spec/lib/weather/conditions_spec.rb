# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Weather::Conditions, type: :lib do
  describe ".current" do
    context 'with 200 success response' do
      before do
        allow_any_instance_of(Faraday::Connection)
          .to receive(:get)
          .and_return(double('response', status: 200, body: JSON.parse(load_fixture('weather', 'conditions'))))
      end

      subject { described_class.current(34.123, -122.123) }

      it 'returns an OpenStruct instance' do
        weather_conditions = subject
        expect(weather_conditions).not_to be_nil
        expect(weather_conditions).to be_instance_of(OpenStruct)
        %i[units name temp temp_min temp_max feels_like humidity pressure description icon].each do |attribute|
          expect(weather_conditions).to respond_to(attribute)
        end
      end
    end

    context 'with an error response' do
      before do
        allow_any_instance_of(Faraday::Connection)
          .to receive(:get)
          .and_raise(Faraday::ClientError.new(body: 'No latitude, Longitude parameter provided'))
      end

      subject { described_class.current('', '') }

      it 'raise an InvalidRequestError' do
        expect { subject }.to raise_exception(Weather::ServiceError, 'No latitude, Longitude parameter provided')
      end
    end
  end
end
