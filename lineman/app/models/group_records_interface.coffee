angular.module('loomioApp').factory 'GroupRecordsInterface', (BaseRecordsInterface, GroupModel) ->
  class GroupRecordsInterface extends BaseRecordsInterface
    model: GroupModel

    fetchByParent: (parentGroup) ->
      @remote.fetch
        path: "#{parentGroup.id}/subgroups"
        cacheKey: "subgroupsFor#{parentGroup.key}"

    archive: (group) =>
      @remote.patchMember group.id, "archive"
