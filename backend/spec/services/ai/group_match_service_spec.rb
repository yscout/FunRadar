require 'rails_helper'

RSpec.describe Ai::GroupMatchService, type: :service do
  let(:event) { create(:event, :with_submitted_preferences, title: 'Weekend Hangout') }
  let(:mock_client) { instance_double(OpenAI::Client) }
  let(:service) { described_class.new(event, client: mock_client) }

  describe '#call' do
    context 'when event has no preferences' do
      let(:event) { create(:event) }
      let(:service) { described_class.new(event, client: mock_client) }

      it 'returns fallback matches' do
        result = service.call
        expect(result).to eq(described_class::FALLBACK_MATCHES)
      end
    end

    context 'when OpenAI returns valid suggestions', :vcr do
      let(:openai_response) do
        {
          "choices" => [
            {
              "message" => {
                "content" => {
                  "matches" => [
                    {
                      "id" => 1,
                      "title" => "Jazz Night",
                      "compatibility" => 92,
                      "image" => "https://example.com/jazz.jpg",
                      "location" => "Blue Note",
                      "price" => "$20/person",
                      "time" => "Saturday, 8:00 PM",
                      "emoji" => "🎵",
                      "votes" => 4,
                      "description" => "Live jazz music"
                    },
                    {
                      "id" => 2,
                      "title" => "Coffee Meetup",
                      "compatibility" => 88,
                      "image" => "https://example.com/coffee.jpg",
                      "location" => "Local Cafe",
                      "price" => "$10/person",
                      "time" => "Sunday, 10:00 AM",
                      "emoji" => "☕",
                      "votes" => 4,
                      "description" => "Casual coffee chat"
                    }
                  ]
                }.to_json
              }
            }
          ]
        }
      end

      before do
        allow(mock_client).to receive(:chat).and_return(openai_response)
      end

      it 'returns the AI-generated matches' do
        result = service.call
        expect(result).to be_an(Array)
        expect(result.length).to eq(2)
        expect(result.first["title"]).to eq("Jazz Night")
      end

      it 'sends correct payload to OpenAI' do
        expect(mock_client).to receive(:chat) do |params|
          messages = params[:parameters][:messages]
          expect(messages.length).to eq(2)
          expect(messages[0][:role]).to eq("system")
          expect(messages[1][:role]).to eq("user")
          
          user_content = JSON.parse(messages[1][:content])
          expect(user_content).to include("event", "attendees", "summary")
          
          openai_response
        end

        service.call
      end

      it 'includes event information in the request' do
        expect(mock_client).to receive(:chat) do |params|
          user_content = JSON.parse(params[:parameters][:messages][1][:content])
          expect(user_content["event"]["title"]).to eq("Weekend Hangout")
          openai_response
        end

        service.call
      end

      it 'includes all attendee preferences' do
        expect(mock_client).to receive(:chat) do |params|
          user_content = JSON.parse(params[:parameters][:messages][1][:content])
          expect(user_content["attendees"].length).to eq(4)
          openai_response
        end

        service.call
      end

      it 'aggregates preferences in summary' do
        expect(mock_client).to receive(:chat) do |params|
          user_content = JSON.parse(params[:parameters][:messages][1][:content])
          summary = user_content["summary"]
          expect(summary).to include("top_time_slots", "top_activities", "budget_range")
          openai_response
        end

        service.call
      end
    end

    context 'when OpenAI returns invalid JSON' do
      before do
        allow(mock_client).to receive(:chat).and_return(
          { "choices" => [{ "message" => { "content" => "invalid json" } }] }
        )
      end

      it 'returns fallback matches' do
        result = service.call
        expect(result).to eq(described_class::FALLBACK_MATCHES)
      end
    end

    context 'when OpenAI returns empty matches' do
      before do
        allow(mock_client).to receive(:chat).and_return(
          { "choices" => [{ "message" => { "content" => '{"matches": []}' } }] }
        )
      end

      it 'returns fallback matches' do
        result = service.call
        expect(result).to eq(described_class::FALLBACK_MATCHES)
      end
    end

    context 'when an error occurs' do
      before do
        allow(mock_client).to receive(:chat).and_raise(StandardError.new("API Error"))
      end

      it 'returns fallback matches' do
        result = service.call
        expect(result).to eq(described_class::FALLBACK_MATCHES)
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).with(/Ai::GroupMatchService failure/)
        service.call
      end
    end

    context 'preference aggregation' do
      it 'tallies time slots correctly' do
        expect(mock_client).to receive(:chat) do |params|
          user_content = JSON.parse(params[:parameters][:messages][1][:content])
          summary = user_content["summary"]
          
          top_times = summary["top_time_slots"]
          expect(top_times).to be_an(Array)
          expect(top_times.first).to include("value", "votes")
          
          {
            "choices" => [{
              "message" => {
                "content" => '{"matches": [{"id": 1, "title": "Test", "compatibility": 80, "image": "test.jpg", "location": "Test", "price": "$10", "time": "Now", "emoji": "🎉", "votes": 1, "description": "Test"}]}'
              }
            }]
          }
        end

        service.call
      end

      it 'tallies activities correctly' do
        expect(mock_client).to receive(:chat) do |params|
          user_content = JSON.parse(params[:parameters][:messages][1][:content])
          summary = user_content["summary"]
          
          top_activities = summary["top_activities"]
          expect(top_activities).to be_an(Array)
          expect(top_activities.first).to include("value", "votes")
          
          {
            "choices" => [{
              "message" => {
                "content" => '{"matches": [{"id": 1, "title": "Test", "compatibility": 80, "image": "test.jpg", "location": "Test", "price": "$10", "time": "Now", "emoji": "🎉", "votes": 1, "description": "Test"}]}'
              }
            }]
          }
        end

        service.call
      end

      it 'calculates budget range across all preferences' do
        expect(mock_client).to receive(:chat) do |params|
          user_content = JSON.parse(params[:parameters][:messages][1][:content])
          summary = user_content["summary"]
          
          budget_range = summary["budget_range"]
          expect(budget_range).to include("min", "max")
          expect(budget_range["min"]).to be_a(Numeric)
          expect(budget_range["max"]).to be_a(Numeric)
          
          {
            "choices" => [{
              "message" => {
                "content" => '{"matches": [{"id": 1, "title": "Test", "compatibility": 80, "image": "test.jpg", "location": "Test", "price": "$10", "time": "Now", "emoji": "🎉", "votes": 1, "description": "Test"}]}'
              }
            }]
          }
        end

        service.call
      end
    end
  end

  describe 'FALLBACK_MATCHES' do
    it 'has valid structure' do
      described_class::FALLBACK_MATCHES.each do |match|
        expect(match).to include(
          "id", "title", "compatibility", "image", "location",
          "price", "time", "emoji", "votes", "description"
        )
        expect(match["id"]).to be_a(Integer)
        expect(match["compatibility"]).to be_between(0, 100)
      end
    end

    it 'provides at least 3 matches' do
      expect(described_class::FALLBACK_MATCHES.length).to be >= 3
    end
  end
end

