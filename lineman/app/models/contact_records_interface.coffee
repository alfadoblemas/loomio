angular.module('loomioApp').factory 'ContactRecordsInterface', (BaseRecordsInterface, ContactModel) ->
  class ContactRecordsInterface extends BaseRecordsInterface
    model: ContactModel

    fetchInvitables: (fragment, groupKey) ->
      @remote.fetch
        params: { q: fragment, group_key: groupKey }
