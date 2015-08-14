Webhooks::Slack::Base = Struct.new(:event) do
  include Routing

  def icon_url
    ""
  end

  def text
    I18n.t :"webhooks.slack.#{event.kind}", author: author.name, name: eventable.name
  end

  def attachments
    [{
      title:       attachment_title,
      text:        attachment_text,
      fields:      Array(attachment_fields),
      fallback:    attachment_fallback
    }]
  end

  alias :read_attribute_for_serialization :send

  private

  def motion_vote_field
    {
      title: "Vote on this proposal",
      value: "#{vote_on_this("agree")} · " +
             "#{vote_on_this("abstain")} · " +
             "#{vote_on_this("disagree")} · " +
             "#{vote_on_this("block")}"
    }
  end

  def view_it_on_loomio_field
    {value: discussion_link(text: "View it on Loomio")}
  end

  def vote_on_this(position)
    discussion_link position, { position: position, proposal_id: eventable.key }
  end

  def discussion_link(text = nil, params = {})
    "<#{discussion_url(eventable.discussion, params)}|#{text || eventable.discussion.title}>"
  end

  def eventable
    @eventable ||= event.eventable
  end

  def author
    @author ||= eventable.author
  end

end
