class Events::NewComment < Event
  def self.publish!(comment)
    event = create!(kind: 'new_comment',
                    eventable: comment,
                    discussion: comment.discussion,
                    created_at: comment.created_at)

    DiscussionReader.for(user: comment.author,
                         discussion: comment.discussion).
                     set_volume_as_required!

    Events::CommentRepliedTo.publish! comment if comment.is_reply?

    comment.mentioned_group_members.
            without(comment.parent_author).find_each do |mentioned_user|
      Events::UserMentioned.publish!(comment, mentioned_user)
    end

    DiscussionReader.for(user: comment.author, discussion: comment.discussion).participate!

    UsersToEmailQuery.new_comment(comment).find_each do |user|
      ThreadMailer.delay.new_comment(user, event)
    end

    comment.discussion.webhooks.each do |webhook|
      WebhookService.publish! webhook: webhook, event: event
    end

    event

  end

  def group_key
    discussion.group.key
  end

  def discussion_key
    discussion.key
  end

  def comment
    eventable
  end
end
