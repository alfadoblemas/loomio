angular.module('loomioApp').controller 'GroupPageController', ($rootScope, $routeParams, Records, CurrentUser, ScrollService, ModalService, GroupWelcomeModal, AbilityService) ->
  $rootScope.$broadcast 'currentComponent', {page: 'groupPage'}

  $rootScope.$on 'newGroupCreated', ->
    ModalService.open GroupWelcomeModal

  Records.groups.findOrFetchByKey($routeParams.key).then (group) =>
    @group = group
    $rootScope.$broadcast 'currentComponent', { page: 'groupPage' }
    $rootScope.$broadcast 'viewingGroup', @group
    $rootScope.$broadcast 'setTitle', @group.fullName()
    MessageChannelService.subscribeTo("/group-#{@group.key}")
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  @isMember = ->
    CurrentUser.membershipFor(@group)?

  @joinGroup = ->
    Records.memberships.initialize(
      group_id: @group.id
      user_id: CurrentUser.id).save()

  @showDescriptionPlaceholder = ->
    AbilityService.canAdminister(@group) and !@group.description

  return
