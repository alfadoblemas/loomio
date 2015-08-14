class Webhooks::Slack::MotionOutcomeCreated < Webhooks::Slack::Base

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
    [view_motion_on_loomio]
  end
end
