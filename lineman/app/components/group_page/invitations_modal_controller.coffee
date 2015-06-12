angular.module('loomioApp').controller 'InvitationsModalController', ($scope, $modalInstance, $translate, group, InvitationsClient, Records, CurrentUser) ->
  $scope.invitableForm =
    group: group
    fragment: ''
  $scope.invitationForm =
    message: $translate 'invitation_form.default_message'
  $scope.invitations = []

  invitationsClient = new InvitationsClient()

  $scope.hasInvitations = ->
    $scope.invitations.length > 0

  $scope.invitationsCount = ->
    _.reduce $scope.invitations, ((total, invitation) -> total + (invitation.count or 1)), 0

  $scope.invitables = ->
    invitables = []
    invitables.push $scope.invitableGroups()
    invitables.push $scope.invitableUsers()
    invitables.push $scope.invitableContacts()
    invitables.push $scope.invitableEmail() if $scope.fragmentIsValidEmail()
    _.take _.flatten(invitables), 10

  $scope.fragmentIsValidEmail = ->
    $scope.invitableForm.$valid

  $scope.invitableEmail = ->
    type: 'email'
    name: "<#{$scope.invitableForm.fragment}>"
    subtitle: $scope.invitableForm.fragment
    email: $scope.invitableForm.fragment

  $scope.invitableGroups = ->
    groups = _.filter $scope.availableGroups(), (group) ->
      group.id != $scope.invitableForm.group.id and
      matchesFragment(group.name) and
      !existsAlready('group', 'id', group.id)

    _.map groups, (group) ->
      id:       group.id
      type:     'group'
      name:     group.name
      subtitle: "Add all #{group.membershipsCount} members"
      image:    group.logoUrl()
      count:    group.membershipsCount

  $scope.invitableUsers = ->
    memberIds = _.uniq _.flatten _.map $scope.availableGroups(), (group) -> group.memberIds()
    memberIds = _.filter memberIds, (memberId) -> 
      !_.contains $scope.invitableForm.group.memberIds(), memberId
    users = _.filter Records.users.find(memberIds), (user) ->
      !user.membershipFor($scope.invitableForm.group) and 
      matchesFragment(user.name, user.username) and
      !existsAlready('user', 'id', user.id)

    _.map users, (user) ->
      id:       user.id
      type:     'user'
      name:     user.name
      subtitle: "@#{user.username}"
      image:    user.avatarUrl

  $scope.invitableContacts = ->
    contacts = _.filter CurrentUser.contacts(), (contact) ->
      matchesFragment(contact.name, contact.email) and 
      !existsAlready('contact', 'email', contact.email)

    _.map contacts, (contact) ->
      type:     'contact'
      name:     contact.name
      email:    contact.email
      subtitle: "<#{contact.email}>"
      image:    contact.avatarUrl

  matchesFragment = (fields...) ->
    _.some _.map fields, (field) ->
      ~field.search new RegExp($scope.invitableForm.fragment, 'i')

  existsAlready = (type, uniqueField, value) ->
    _.some _.map $scope.invitations, (invitation) ->
      invitation.type == type and invitation[uniqueField] = value

  $scope.getInvitables = ->
    fragment = $scope.invitableForm.fragment
    groupKey = $scope.invitableForm.group.key
    Records.contacts.fetchInvitables(fragment, groupKey).then $scope.invitables
    Records.memberships.fetchInvitables(fragment, groupKey).then $scope.invitables
    $scope.invitables()

  $scope.availableGroups = ->
    CurrentUser.groups()

  $scope.addInvitation = (invitation) ->
    $scope.invitableForm.fragment = ''
    $scope.invitations.push invitation

  $scope.submit = ->
    $scope.isDisabled = true
    invitationsClient.create(invitationsParams()).then($scope.saveSuccess, $scope.saveError)

  invitationsParams = ->
    invitations: $scope.invitations
    group_id: $scope.invitableForm.group.id
    message: $scope.invitationForm.message

  $scope.cancel = ($event) ->
    $event.preventDefault()
    $modalInstance.dismiss('cancel')

  $scope.saveSuccess = ->
    $scope.isDisabled = false
    $scope.invitations = []
    $modalInstance.close()
    # Repopulate newly added members for group
    Records.memberships.fetchByGroup $scope.invitableForm.group

  $scope.saveError = (error) ->
    $scope.isDisabled = false
    $scope.errorMessages = error.error_messages

  return
