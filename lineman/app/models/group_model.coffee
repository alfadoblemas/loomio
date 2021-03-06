angular.module('loomioApp').factory 'GroupModel', (BaseModel) ->
  class GroupModel extends BaseModel
    @singular: 'group'
    @plural: 'groups'
    @indices: ['id', 'key', 'parentId']

    defaultValues: ->
      parentId: null

    setupViews: ->
      @setupView 'discussions', 'createdAt', true
      @setupView 'membershipRequests', 'createdAt', true
      @setupView 'invitations', 'createdAt', true

    discussions: ->
      @discussionsView.data()

    membershipRequests: ->
      @membershipRequestsView.data()

    invitations: ->
      @invitationsView.data()

    pendingMembershipRequests: ->
      _.filter @membershipRequestsView.data(), (membershipRequest) ->
        membershipRequest.isPending()

    hasPendingMembershipRequests: ->
      _.some @pendingMembershipRequests()

    hasPendingMembershipRequestFrom: (user) ->
       _.some @pendingMembershipRequests(), (request) ->
        request.requestorId == user.id

    previousMembershipRequests: ->
      _.filter @membershipRequestsView.data(), (membershipRequest) ->
        !membershipRequest.isPending()

    hasPreviousMembershipRequests: ->
      _.some @previousMembershipRequests()

    pendingInvitations: ->
      _.filter @invitationsView.data(), (invitation) ->
        invitation.isPending()

    hasPendingInvitations: ->
      _.some @pendingInvitations()

    organisationDiscussions: ->
      @recordStore.discussions.find(groupId: { $in: @organisationIds()})

    organisationIds: ->
      _.pluck(@subgroups(), 'id').concat(@id)

    organisationSubdomain: ->
      if @isSubgroup()
        @parent().subdomain
      else
        @subdomain  

    subgroups: ->
      if @isParent()
        @recordStore.groups.find(parentId: @id)
      else
        []

    memberships: ->
      @recordStore.memberships.find(groupId: @id)

    membershipFor: (user) ->
      _.find @memberships(), (membership) -> membership.userId == user.id

    members: ->
      @recordStore.users.find(id: {$in: @memberIds()})

    adminMemberships: ->
      _.filter @memberships(), (membership) -> membership.admin

    admins: ->
      adminIds = _.map(@adminMemberships(), (membership) -> membership.userId)
      @recordStore.users.find(id: {$in: adminIds})

    coordinatorsIncludes: (user) ->
      _.some @recordStore.memberships.where(groupId: @id, userId: user.id)

    memberIds: ->
      _.map @memberships(), (membership) -> membership.userId

    adminIds: ->
      _.map @adminMemberships(), (membership) -> membership.userId

    fullName: (separator = '-') ->
      if @parentId?
        "#{@parentName()} #{separator} #{@name}"
      else
        @name

    parent: ->
      @recordStore.groups.find(@parentId)

    parentName: ->
      @parent().name if @parent()?

    parentIsHidden: ->
      @parent().visibleToPublic() if @parentId?

    visibleToPublic: ->       @visibleTo == 'public'
    visibleToOrganisation: -> @visibleTo == 'parent_members'
    visibleToMembers: ->      @visibleTo == 'members'

    isSubgroup: ->
      @parentId?

    isArchived: ->
      @archivedAt?

    isParent: ->
      !@parentId?

    logoUrl: ->
      if @logoUrlMedium
        @logoUrlMedium
      else if @isSubgroup()
        @parent().logoUrl()
      else
        '/img/default-logo-medium.png'

    coverUrl: ->
      if @coverUrlDesktop
        @coverUrlDesktop
      else if @isSubgroup()
        @parent().coverUrl()
      else
        '/img/default-cover-photo.png'

    archive: ->
      # is this broken (group null right?)
      @restfulClient.postMember(group.key, 'archive')
