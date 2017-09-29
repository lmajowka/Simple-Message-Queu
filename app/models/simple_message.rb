class SimpleMessage

  attr_accessor :message_body, :message_attributes, :message_id, :md5_of_message_body, :md5_of_message_attributes

  def initialize(params)
    @message_body = params[:MessageBody]
    @message_id = SecureRandom.hex(16)
    @message_attributes = get_message_attributes_from_params params
    @md5_of_message_body = Digest::MD5.hexdigest params[:MessageBody]
    @md5_of_message_attributes = Digest::MD5.hexdigest @message_attributes.to_s
  end

  private

  def get_message_attributes_from_params(params)
    attributes = []
    n = 1
    while params["MessageAttribute.#{n}.Name".to_sym].present? do
      attributes << {
        name: params["MessageAttribute.#{n}.Name".to_sym],
        value: params["MessageAttribute.#{n}.Value".to_sym]
      }
      n += 1
    end
    attributes
  end

end