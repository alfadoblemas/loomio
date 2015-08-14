class Webhooks::Slack::MotionOutcomeUpdated < Webhooks::Slack::Base

  def attachment_fallback
    "*#{eventable.name}*\n#{eventable.outcome}\n"
  end

  def attachment_title
    eventable.name
  end

  def attachment_text
    eventable.outcome
  end

  def attachment_fields
    view_it_on_loomio_field
  end
end
