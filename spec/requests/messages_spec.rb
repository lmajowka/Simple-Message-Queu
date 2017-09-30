require 'rails_helper'

RSpec.describe 'messages', type: :request do

  describe '#send_message' do

    context 'without required params' do

      it 'fails to send a message' do
        post '/SendMessage'
        expect(response.status).to eq 422
      end

    end

    context 'with required params' do

      it 'sends a simple message' do
        post '/SendMessage', params: { MessageBody: 'Message Body', QueueUrl: 'default' }
        expect(response.status).to eq 200
      end

    end

  end

  describe '#receive_message' do

    context 'no messages to receive' do

      before do
        $redis.flushall
      end

      it 'receives an empty list of messages' do
        get '/ReceiveMessage', params: { QueueUrl: 'default' }
        message_results = JSON.parse response.body
        expect(message_results['ReceiveMessageResult']).to eq([])
      end

    end

    context 'with messages on the queue' do

      before do
        $redis.flushall
        post '/SendMessage', params: { MessageBody: 'Message Body', QueueUrl: 'default' }
      end

      it 'receives an empty list of messages' do
        get '/ReceiveMessage', params: { QueueUrl: 'default' }
        message_results = JSON.parse response.body
        expect(message_results['ReceiveMessageResult']).to eq([])
      end

    end

  end

end
