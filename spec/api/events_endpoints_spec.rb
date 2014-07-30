require 'api_spec_helper'
require 'icalendar'

RSpec.shared_examples 'events endpoint' do
  let(:events_cnt) { 3 }

  # Events from 2014-04-01 to 2014-04-03
  let!(:events) do
    i = 0
    Fabricate.times(events_cnt, :event) do
      starts_at { "2014-04-0#{i+=1} 14:30" } # XXX sequencer in times doesn't work
      ends_at { "2014-04-0#{i} 16:00" }
    end
  end
  let(:event) { events.first }

  let(:event_json) do
    {
      id: event.id,
      name: event.name,
      starts_at: event.starts_at,
      ends_at: event.ends_at
    }.to_json
  end

  include_context 'API response'
  subject { body }

  context 'with default parameters' do
    before { get path }

    it 'returns OK' do
      expect(status).to eql(200)
    end

    it 'returns a JSON-API format' do
      expect(body).to have_json_size(events_cnt).at_path('events')
    end
  end

  context 'with pagination' do
    before { get "#{path}?limit=1&offset=1" }
    it { should have_json_size(1).at_path('events') }
  end

  context 'with date filtering' do
    before { get "#{path}?from=2014-04-02T13:50&to=2014-04-03T00:00" }
    it { should have_json_size(1).at_path('events') }
  end

  context 'as an icalendar' do
    before { get '/events.ical' }

    it 'returns a valid content-type' do
      expect(headers['Content-Type']).to eql('text/calendar')
    end

    it 'returns a valid iCalendar' do
      calendar = Icalendar.parse(body).first
      expect(calendar.events.size).to eq(events_cnt)
    end
  end

end


describe API::EventsEndpoints do
  subject { response }
  let(:status) { response.status }
  let(:body) { response.body }
  let(:headers) { response.headers }

  let(:events_cnt) { 3 }
  let(:event) { events.first }

  let(:event_json) do
    {
      id: event.id,
      name: event.name,
      starts_at: event.starts_at,
      ends_at: event.ends_at
    }.to_json
  end

  describe 'GET /events' do
    let(:path) { '/events' }
    it_behaves_like 'events endpoint'
  end

  describe 'GET /events/:id' do
    context 'JSON-API format' do
      before { get "/events/#{event.id}" }
      subject { body }

      it 'returns OK' do
        expect(status).to eql(200)
      end

      it { should have_json_size(1).at_path('events') }

      it { should be_json_eql(event_json).at_path('events/0') }

    end

    context 'with non-existent resource' do
      before { get "/events/9001" }
      it 'returns Not Found' do
        expect(status).to eql(404)
      end
    end
  end
end
