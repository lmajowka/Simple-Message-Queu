class SimpleMessage

  attr_accessor :message_body, :message_attributes, :message_id, :md5_of_message_body, :md5_of_message_attributes

  def initialize(params = nil)
    if params.present?
      params.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end
  end

  def self.convert(params)
    simple_message = new
    simple_message.message_body = params[:MessageBody]
    simple_message.message_id = SecureRandom.hex(16)
    simple_message.message_attributes = get_message_attributes_from_params params
    simple_message.md5_of_message_body = Digest::MD5.hexdigest params[:MessageBody]
    simple_message.md5_of_message_attributes = Digest::MD5.hexdigest @message_attributes.to_s
    simple_message
  end

  def render
    {
      MessageBody: message_body,
      MessageId: message_id,
      MD5OfMessageBody: md5_of_message_body,
      MD5OfMessageAttributes: md5_of_message_attributes
    }
  end

  private

  def self.get_message_attributes_from_params(params)
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