Article = Ember.Object.extend(
  title: ""
  content: ""
  chunks: (->
    console.log  "computing content..." + @content
    if @content is `undefined`
      []
    else
      console.log('computing chunks')
      chunks = @get("content").match(/([^,.、。]+)([,.、。]+)/g)
      return []  unless chunks
      object_chunks = []
      position = 0
      chunks.forEach (item, index, self) ->
        chunk = Ember.Object.create(
          selected: false
          position: position
          length: item.length
          content: item
          letters: item.split("").map((item, index, self) ->
            Ember.Object.create
              content: item
              index: index
              chunk_start: position
              active: false
          )
        )
        object_chunks.push chunk
        position = position + item.length
      object_chunks
  ).property("content")
)

ArticlesController = Ember.ArrayController.create(
  content: []
  sync: ->
    $.get("/articles", (articles)->
      ArticlesController.pushObject Article.create(a) for a in articles
    , 'json')
    console.log "Finished sync..."
    @select(ArticlesController.get('firstObject'))

  selected: (->
    @_selected
  ).property("_selected")
  _selected : null
  select: (article) ->
    @set('_selected', article)
)


WordsController = Ember.ArrayController.create(
  content: []
  sync: ->
    $.get("/words", (words)->
      WordsController.pushObject Word.create(w) for w in words
    , 'json')
)

ResultsController = Ember.ArrayController.create(content:[])

ResultView = Ember.View.extend(
  layoutName: "templates_result_layout"
  templateName: "templates_result" 
  resultBinding: "App.ResultsController"
  add: (event) ->
    word = event.context
    word.save()
    WordsController.pushObject word
    ResultsController.set 'content', Ember.A()
  close: (event) ->
    console.log "clearing results"
    @result.set('content',Ember.A())
)

Word = Ember.Object.extend(
  kanji : ""
  kana :""
  description : ""
  save : ->
    word =  
      word:  
        id: @id || null
        kanji: @kanji
        kana: @kana
        desc: @desc
        article_id: @article_id
    $.post('words',word)
)

app = Ember.Application.create(
)

ToogableView = Ember.Mixin.create(
  toogle: (key) ->
    if @get(key)
      @set key, false
    else
      @set key, true
  )


SelectedChunkView = Ember.CollectionView.extend(
  classNameBindings: ["hidden"]
  content: (->
    return []  if @text is `undefined`
    @getPath "text.letters"
  ).property("text")
  classNames: "nav nav-pills"
  tagName: "ul"
  itemViewClass: Ember.View.extend(ToogableView,
    tagName: "li"
    activeBinding: "content.active"
    classNameBindings: ["active"]
    template: Ember.Handlebars.compile("<a href='#'>{{content.content}}</a>")
    click: (event) ->
      @toogle "active"
      console.log @content.index + @content.chunk_start
  )
)

TextChunk = Ember.View.extend(
  hidden: (->
    not @get("active")
  ).property("active")
  templateName: "templates_text_chunk" 
  search: (event) ->
    selection = @getPath("content.letters").filter((item) ->
      item.get "active"
    ).map((item) ->
      item.content
    ).join("")
    console.log selection
    console.log "/dictionary/word/" + selection
    $.get "/dictionary/word/" + selection, (data) ->
      
      ResultsController.pushObject(
        Word.create(
          kanji: item[0]
          kana: item[1]
          desc: item[2]
          article_id: 1
        )
      ) for item in data
      #make some button to select word and then add word to words collection
      #App.data.articles.get('selected').words.push(result.get('firstObject'))

)

SelectableChunks = Ember.View.extend(
  templateName: "templates_chunk_list"
  contentBinding: "App.ArticlesController.selected.chunks"
  select: (event)->
    chunk.set('selected', false) for chunk in @content
    event.context.set('selected', true)
    console.log 'selected: ', event.context.content
  selected: (->
    #return chunk if chunk.get('selected') for chunk in @content
    App.ArticlesController.selected.chunks[0]
  ).property("App.ArticlesController.selected.chunks")
)

ArticlesList = Ember.View.extend(
  contentBinding: 'App.ArticlesController'
  itemViewClass: ArticlesList
  templateName: "templates_articles_list"
  select: (event)->
    console.log 'selecting' + event.context
    ArticlesController.select(event.context)
)

#$("body").append("<div class=\"alert alert-info\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\">×</button>"+result_html+"</div>")
app.SelectableChunks =  SelectableChunks
app.SelectedChunkView = SelectedChunkView
app.WordsController = WordsController
app.ArticlesController = ArticlesController
app.ResultsController = ResultsController
app.ResultView = ResultView
app.ArticlesList = ArticlesList
app.TextChunk = TextChunk
window.App = app
ArticlesController.sync()
WordsController.sync()
#chunks.append()
