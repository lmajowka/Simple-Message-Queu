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
        message_result = JSON.parse response.body
        expect(message_result['MessageId']).not_to be_empty
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

    context 'with 1 message on the queue' do

      before do
        $redis.flushall
        post '/SendMessage', params: { MessageBody: 'Message Body', QueueUrl: 'default' }
      end

      it 'receives 1 messages' do
        get '/ReceiveMessage', params: { QueueUrl: 'default' }
        message_results = JSON.parse response.body
        expect(message_results['ReceiveMessageResult'].first['MessageBody']).to eq('Message Body')
      end

    end

    context 'with a message on other queue' do

      before do
        $redis.flushall
        post '/SendMessage', params: { MessageBody: 'Message Body', QueueUrl: 'default' }
      end

      it 'receives 1 messages' do
        get '/ReceiveMessage', params: { QueueUrl: 'new_queue' }
        message_results = JSON.parse response.body
        expect(message_results['ReceiveMessageResult']).to eq([])
      end

    end

    context 'with multiple messages' do

      before do
        $redis.flushall
        post '/SendMessage', params: {
          MessageBody: 'Message Body 1',
          QueueUrl: 'default',
        }
        post '/SendMessage', params: { MessageBody: 'Message Body 2', QueueUrl: 'default' }
      end

      it 'receives 2 messages' do
        get '/ReceiveMessage', params: { QueueUrl: 'default' }
        message_results = JSON.parse response.body
        expect(message_results['ReceiveMessageResult'].size).to eq(2)
      end


    end

    context 'with multiple attributes' do

      before do
        $redis.flushall
        post '/SendMessage', params: {
          MessageBody: 'Message Body 1',
          QueueUrl: 'default',
          'MessageAttribute.1.Name' => 'MyAttribute1',
          'MessageAttribute.1.Value' => 'MyValue1',
          'MessageAttribute.2.Name' => 'MyAttribute2',
          'MessageAttribute.2.Value' => 'MyValue2',
          'MessageAttribute.3.Name' => 'MyAttribute3',
          'MessageAttribute.3.Value' => 'MyValue3'
        }
      end

      it 'receives attributes on the message' do
        get '/ReceiveMessage', params: { QueueUrl: 'default' }
        message_results = JSON.parse response.body
        message = message_results['ReceiveMessageResult'].first
        expect(message["MessageAttribute.1.Name"]).to eq('MyAttribute1')
        expect(message["MessageAttribute.1.Value"]).to eq('MyValue1')
        expect(message["MessageAttribute.2.Name"]).to eq('MyAttribute2')
        expect(message["MessageAttribute.2.Value"]).to eq('MyValue2')
        expect(message["MessageAttribute.3.Name"]).to eq('MyAttribute3')
        expect(message["MessageAttribute.3.Value"]).to eq('MyValue3')
      end

    end


  end

end
