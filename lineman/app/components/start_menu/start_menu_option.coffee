angular.module('loomioApp').directive 'startMenuOption', ->
  scope: {text: '@', icon: '@', action: '@', group: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/start_menu/start_menu_option.html'
  replace: true,
  controller: ($scope, ModalService, InvitationForm, DiscussionForm, StartGroupForm, Records, CurrentUser) ->
    $scope.openModal = ->
      switch $scope.action
        when 'invitePeople' then ModalService.open InvitationForm
        when 'startGroup' then ModalService.open StartGroupForm, group: -> Records.groups.initialize()
        when 'startThread' then ModalService.open DiscussionForm, discussion: -> Records.discussions.initialize(uses_markdown: true)
