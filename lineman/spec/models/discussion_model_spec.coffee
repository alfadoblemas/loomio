describe 'DiscussionModel', ->
  discussion = null
  discussionReader = null
  author = null
  recordStore = null
  proposal = null
  group = null
  event = null
  otherEvent = null
  comment = null

  beforeEach module 'loomioApp'

  beforeEach ->
    inject (Records) ->
      recordStore = Records

    group = recordStore.groups.import(id: 1, name: 'group')
    author = recordStore.users.import(id: 1, name: 'Sam')

    discussion = recordStore.discussions.import(id: 1, key: 'key', author_id: author.id, group_id: group.id, title: 'Hi', created_at: "2015-01-01T00:00:00Z" )

    event = recordStore.events.import(id: 1, sequence_id: 1, discussion_id: 1)
    otherEvent = recordStore.events.import(id: 2, sequence_id: 2, discussion_id: 2)
    discussionReader = recordStore.discussionReaders.import(discussion_id: 1)

  describe 'author()', ->
    it 'returns the discussion author', ->
      discussion.authorId = author.id
      expect(discussion.author()).toBe(author)

  describe 'comments()', ->
    beforeEach ->
      comment = recordStore.comments.import(id:5, discussion_id: discussion.id)

    it 'returns comments', ->
      expect(discussion.comments()).toContain(comment)

  describe 'proposals()', ->
    beforeEach ->
      proposal = recordStore.proposals.import(id:7, discussion_id: discussion.id)

    it 'returns proposals', ->
      expect(discussion.proposals()).toContain(proposal)
      expect(discussion.proposals().length).toBe(1)

  describe 'group()', ->
    it 'returns its group', ->
      expect(discussion.group()).toBe(group)

  describe 'events()', ->
    it 'returns events for the discussion', ->
      expect(discussion.events()).toContain(event)

    it 'does not return events for another discussion', ->
      expect(discussion.events()).not.toContain(otherEvent)

  describe 'reader', ->

    it "returns the discussion reader associated with this discussion", ->
      expect(discussion.reader()).toBe(discussionReader)

  describe 'clone()', ->
    beforeEach ->
      window.Loomio =
        permittedParams:
          discussion: ['title', 'author_id']

    it 'copies all of the attributes of the object being cloned', ->
      expect(discussion.clone().title).toBe(discussion.title)

    it 'copies values not present in the permitted params', ->
      expect(discussion.clone().key).toBe(discussion.key)

    it 'copies all of the methods of the object being closed', ->
      expect(discussion.clone().authorName()).toBe(discussion.authorName())

    it 'does not create a new entry in the record store', ->
      discussion.clone()
      expect(recordStore.discussions.where(id: discussion.id).length).toBe(1)
      expect(recordStore.discussions.where(title: discussion.title).length).toBe(1)

    it 'inherits key and id from the original record', ->
      clone = discussion.clone()
      expect(clone.id).toBe(discussion.id)
      expect(clone.key).toBe(discussion.key)

    it 'does not update original record unless saved', ->
      clone = discussion.clone()
      clone.title = 'New title'
      expect(recordStore.discussions.find(discussion.id).title).not.toBe('New title')
