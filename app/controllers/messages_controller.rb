class MessagesController < ApplicationController

  SEND_MESSAGE_REQUIRED_PARAMS = [:MessageBody, :QueueUrl]

  def send_message

    if missing_send_message_required_params.presence
      return render json: {error: "Missing params: #{missing_send_message_required_params.join(', ')}"}, status: :unprocessable_entity
    end

    simple_message = SimpleMessage.new params

    SimpleQueue.push params[:QueueUrl], simple_message

    render json: {
      MessageId: simple_message.message_id,
      MD5OfMessageBody: simple_message.md5_of_message_body,
      MD5OfMessageAttributes: simple_message.md5_of_message_attributes
    }
  end

  private

  def missing_send_message_required_params
    missing_required_params = []
    SEND_MESSAGE_REQUIRED_PARAMS.each do |param|
      unless params[param].present?
        missing_required_params << param
      end
    end
    missing_required_params
  end

end
