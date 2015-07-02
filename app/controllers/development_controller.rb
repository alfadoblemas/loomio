class DevelopmentController < ApplicationController
  around_filter :ensure_testing_environment

  def last_email
    @email = ActionMailer::Base.deliveries.last
    render layout: false
  end

  def discussion_url(discussion)
    "http://localhost:8000/d/#{discussion.key}/"
  end

  def group_url(group)
    "http://localhost:8000/g/#{group.key}/"
  end

  def setup_group
    cleanup_database
    test_group
    sign_in patrick
    redirect_to group_url(test_group)
  end

  def setup_group_for_invitations
    setup_group
    another_test_group
    patricks_contact
  end

  def setup_discussion
    cleanup_database
    test_discussion
    sign_in patrick
    redirect_to discussion_url(test_discussion)
  end

  def setup_proposal
    cleanup_database
    sign_in patrick
    test_proposal

    redirect_to discussion_url(test_discussion)
  end

  def setup_proposal_with_votes
    cleanup_database
    sign_in patrick
    test_vote
    another_test_vote

    redirect_to discussion_url(test_discussion)
  end

  def setup_closed_proposal
    cleanup_database
    sign_in patrick
    test_proposal
    MotionService.close(test_proposal)
    redirect_to discussion_url(test_discussion)
  end

  def setup_closed_proposal_with_outcome
    cleanup_database
    sign_in patrick
    MotionService.close(test_proposal)
    MotionService.create_outcome(motion: test_proposal,
                                 params: {outcome: 'Were going hiking tomorrow'},
                                 actor: patrick)
    redirect_to discussion_url(test_discussion)
  end

  def setup_membership_requests
    cleanup_database
    sign_in patrick
    test_group
    another_test_group
    membership_request_from_logged_out
    membership_request_from_user
    redirect_to group_url(test_group)
  end

  def setup_all_notifications
    cleanup_database
    sign_in patrick

    #'comment_liked'
    comment = Comment.new(discussion: test_discussion, body: 'I\'m rather likeable')
    new_comment_event = CommentService.create(comment: comment, actor: patrick)
    comment_liked_event = CommentService.like(comment: comment, actor: jennifer)

    #'motion_closing_soon'
    motion_created_event = MotionService.create(motion: test_proposal,
                                                actor: jennifer)
    closing_soon_event = Events::MotionClosingSoon.publish!(test_proposal)

    #'motion_outcome_created'
    outcome_event = MotionService.create_outcome(motion: test_proposal,
                                                 params: {outcome: 'Were going hiking tomorrow'},
                                                 actor: jennifer)

    #'comment_replied_to'
    reply_comment = Comment.new(discussion: test_discussion,
                                body: 'I agree with you', parent: comment)
    CommentService.create(comment: reply_comment, actor: jennifer)

    #'user_mentioned'
    comment = Comment.new(discussion: test_discussion, body: 'hey @patrickswayze you look great in that tuxeido')
    CommentService.create(comment: comment, actor: jennifer)

    #'membership_requested',
    membership_request = MembershipRequest.new(name: 'The Ghost', email: 'boooooo@invisible.co', group: test_group)
    event = MembershipRequestService.create(membership_request: membership_request, actor: LoggedOutUser.new)

    #'membership_request_approved',
    another_group = Group.new(name: 'Stars of the 90\'s', is_visible_to_public: true)
    GroupService.create(group: another_group, actor: jennifer)
    membership_request = MembershipRequest.new(requestor: patrick, group: another_group)
    event = MembershipRequestService.create(membership_request: membership_request, actor: patrick)
    approval_event = MembershipRequestService.approve(membership_request: membership_request, actor: jennifer)

    #'user_added_to_group',
    #notify patrick that he has been added to jens group
    another_group = Group.new(name: 'Planets of the 80\'s')
    GroupService.create(group: another_group, actor: jennifer)
    MembershipService.add_users_to_group(users: [patrick], group: another_group, inviter: jennifer, message: 'join in')

    redirect_to discussion_url(test_discussion)
  end

  private

  def ensure_testing_environment
    raise "Do not call me." if Rails.env.production?
    tmp, Rails.env = Rails.env, 'test'
    yield
    Rails.env = tmp
  end

  def patrick
    @patrick ||= User.create!(name: 'Patrick Swayze',
                              email: 'patrick_swayze@example.com',
                              username: 'patrickswayze',
                              password: 'gh0stmovie',
                              angular_ui_enabled: true)
  end

  def patricks_contact
    if patrick.contacts.empty?
      patrick.contacts.create(name: 'Keanu Reeves',
                              email: 'keanu@example.com',
                              source: 'gmail')
    end
  end

  def jennifer
    @jennifer ||= User.create!(name: 'Jennifer Grey',
                               email: 'jennifer_grey@example.com',
                               username: 'jennifergrey',
                               password: 'gh0stmovie',
                               angular_ui_enabled: true)
  end

  def max
    @max ||= User.create!(name: 'Max Von Sydow',
                          email: 'max@example.com',
                          password: 'gh0stmovie',
                          username: 'mingthemerciless',
                          angular_ui_enabled: true)
  end

  def emilio
    @emilio ||= User.create!(name: 'Emilio Estevez',
                            email: 'emilio@loomio.org',
                            password: 'gh0stmovie',
                            angular_ui_enabled: true)
  end

  def test_group
    unless @test_group
      @test_group = Group.create!(name: 'Dirty Dancing Shoes',
                                  membership_granted_upon: 'approval',
                                  is_visible_to_public: true,
                                  is_visible_to_parent_members: false)
      @test_group.add_admin!  patrick
      @test_group.add_member! jennifer
      @test_group.add_member! emilio
    end
    @test_group
  end

  def another_test_group
    unless @another_test_group
      @another_test_group = Group.create!(name: 'Point Break')
      @another_test_group.add_admin! patrick
      @another_test_group.add_member! max
    end
    @another_test_group
  end

  def test_discussion
    unless @test_discussion
      @test_discussion = Discussion.create!(title: 'What star sign are you?', group: test_group, author: jennifer, private: true)
    end
    @test_discussion
  end

  def test_proposal
    unless @test_proposal
      @test_proposal = Motion.new(name: 'lets go hiking',
                                closing_at: 3.days.from_now,
                                discussion: test_discussion)
      MotionService.create(motion: @test_proposal, actor: jennifer)
    end
    @test_proposal
  end

  def test_vote
    unless @test_vote
      @test_vote = Vote.new(position: 'yes', motion: test_proposal, statement: 'I agree!')
      VoteService.create(vote: @test_vote, actor: patrick)
    end
    @test_vote
  end

  def another_test_vote
    unless @another_test_vote
      @another_test_vote = Vote.new(position: 'no', motion: test_proposal, statement: 'I disagree!')
      VoteService.create(vote: @another_test_vote, actor: jennifer)
    end
    @another_test_vote
  end

  def membership_request_from_logged_out
    unless @membership_request_from_logged_out
      @membership_request_from_logged_out = MembershipRequest.new(group: test_group,
                                                                  name: 'Marjorie Houseman',
                                                                  email: 'marjorie@example.com')
      MembershipRequestService.create(membership_request: @membership_request_from_logged_out)
    end
    @membership_request_from_logged_out
  end

  def membership_request_from_user
    unless @membership_request_from_user
      @membership_request_from_user = MembershipRequest.new(group: test_group,
                                                            requestor: max)
      MembershipRequestService.create(membership_request: @membership_request_from_user)
    end
    @membership_request_from_user
  end

  def cleanup_database
    User.delete_all
    Group.delete_all
    ActionMailer::Base.deliveries = []
  end
end
