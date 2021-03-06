angular.module('loomioApp').factory 'InvitationRecordsInterface', (BaseRecordsInterface, InvitationModel) ->
  class InvitationRecordsInterface extends BaseRecordsInterface
    model: InvitationModel

    fetchPendingByGroup: (groupKey, options = {}) ->
      options['group_key'] = groupKey
      @restfulClient.get('/pending', options)
