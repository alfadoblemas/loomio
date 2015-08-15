angular.module('loomioApp').factory 'DidNotVoteRecordsInterface', (BaseRecordsInterface, DidNotVoteModel) ->
  class DidNotVoteRecordsInterface extends BaseRecordsInterface
    model: DidNotVoteModel

    fetchByProposal: (proposalKey, options = {}) ->
      @remote.fetch
        params:
          motion_id: proposalKey
          per: options['per']
