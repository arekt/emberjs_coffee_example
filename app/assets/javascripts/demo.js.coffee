Article = Ember.Object.extend(
  id: 0
  title: ""
  content: ""
  position: 0
  length: 10
  zoomed_letters: (->
    ac = Ember.ArrayController.create(content:[])
    ac.pushObject({letter: @content.slice(@position)[index] || '', id:index}) for index in [0..@length]
    return ac
    ).property('content','position')
  selectable_content: (->
    lettersArray =[]
    lettersArray = @get('content').split('') if @get('content')
    ac = Ember.ArrayController.create(content:[])
    ac.pushObject({k:i, v:lettersArray[i]}) for i in [0..lettersArray.length]
    ac
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
    WordsController.sync(article)
)

WordsController = Ember.ArrayController.create(
  content: []
  find: (word_id)->
    console.log "find("+word_id+")"
    word = @get("content").findProperty("id", parseInt(word_id))
    word
  word_position: ->
    parseInt(ArticlesController.get('selected').get('position'))+parseInt($('ul#letters li.active').first().attr('id') || 0 )
  sync: (article)->
    @set("content",[])
    position = 
    $.get("/articles/"+article.id+"/words?position="+@word_position(), (words)->
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
  position: 0
  kanji : ""
  kana :""
  desc : ""
  article_id : ""
  mode: "kanji"
  display: (->
    @get(@mode)
  ).property("mode") 
  save : ->
    word =  
      word:  
        id: @id || null
        kanji: @kanji
        kana: @kana
        desc: @desc
        article_id: @article_id
        position: @position
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

ArticleView = Ember.View.extend(
  contentBinding: 'App.ArticlesController.selected'
  templateName: "templates_article"
  length: (->
    @content.length
  ).property('content')
  select: (event)->
    li = $(event.target).closest('li')
    if li.hasClass('active')
      li.removeClass('active')
    else
      li.addClass('active')
      $('a.popover').popover('hide')
    
  move_left: ->
    @content.set 'position', @content.get('position') - 1 
  move_right: ->
    @content.set 'position', @content.get('position') + 1 

  search: (event) ->
    selection = $('ul#letters li.active').text()
    $.get "/dictionary/word/" + selection, (data) ->
      
      ResultsController.pushObject(
        Word.create(
          position: WordsController.word_position()
          kanji: item[0]
          kana: item[1]
          desc: item[2]
          article_id: App.ArticlesController.get('selected').id
        )
      ) for item in data
  set_zoom: (event) ->
    @get('content').set('position', event.target.id)
    WordsController.sync(ArticlesController.get('selected'))
    console.log event.target.id
    console.log @content.get('zoomed_letters').content
)

ArticlesList = Ember.View.extend(
  contentBinding: 'App.ArticlesController'
  itemViewClass: ArticlesList
  templateName: "templates_articles_list"
  select: (event)->
    console.log 'selecting' + event.context
    ArticlesController.select(event.context)
)

WordsView = Ember.View.extend(
  click: (event) ->
    jq_word = $(event.target).closest("a")
    word = WordsController.find(jq_word.attr('id'))
    if word.get('mode') == "kanji"
      word.set('mode',"kana")
    else
      word.set('mode',"kanji")
)


#$("body").append("<div class=\"alert alert-info\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\">×</button>"+result_html+"</div>")
app.WordsController = WordsController
app.ArticlesController = ArticlesController
app.ResultsController = ResultsController
app.ResultView = ResultView
app.ArticlesList = ArticlesList
app.ArticleView = ArticleView
app.WordsView = WordsView
window.App = app
ArticlesController.sync()

#chunks.append()
