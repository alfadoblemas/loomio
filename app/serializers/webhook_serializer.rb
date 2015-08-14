class WebhookSerializer < ActiveModel::Serializer
  attributes :text, :attachments, :icon_url
end
