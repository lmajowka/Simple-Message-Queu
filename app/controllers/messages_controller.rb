class MessagesController < ApplicationController

  SEND_MESSAGE_REQUIRED_PARAMS = [:MessageBody, :QueueUrl]
  RECEIVE_MESSAGE_REQUIRED_PARAMS = [:QueueUrl]
  MAX_NUMBER_OF_MESSAGES = 10

  def send_message

    missing_params = missing_required_params(SEND_MESSAGE_REQUIRED_PARAMS)
    if missing_params.presence
      return render json: {error: "Missing params: #{missing_params.join(', ')}"}, status: :unprocessable_entity
    end

    simple_message = SimpleMessage.convert params

    SimpleQueue.push params[:QueueUrl], simple_message

    render json: {
      MessageId: simple_message.message_id,
      MD5OfMessageBody: simple_message.md5_of_message_body,
      MD5OfMessageAttributes: simple_message.md5_of_message_attributes
    }
  end

  def receive_message

    missing_params = missing_required_params(RECEIVE_MESSAGE_REQUIRED_PARAMS)
    if missing_params.presence
      return render json: {error: "Missing params: #{missing_params.join(', ')}"}, status: :unprocessable_entity
    end

    messages = []
    while message = SimpleQueue.pop( params[:QueueUrl]) do
      messages << SimpleMessage.new(message).render
      break if messages.size > MAX_NUMBER_OF_MESSAGES
    end

    render json: {ReceiveMessageResult: messages}
  end

  private

  def missing_required_params(list_of_required_params)
    missing_required_params = []
    list_of_required_params.each do |param|
      unless params[param].present?
        missing_required_params << param
      end
    end
    missing_required_params
  end

end
