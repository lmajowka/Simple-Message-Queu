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

end
