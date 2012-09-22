Article = Ember.Object.extend(
  title: ""
  content: ""
  position: 0
  length: 20
  line: (->
    @content.slice @position, @position+@length
    ).property('position')
  letters: (->
    lettersArray = []
    lettersArray = @get('line').split('') if @get('line')
    return Ember.ArrayController.create(
      content: lettersArray) 
    ).property("line")
  a: ()->
    "aaxxa"
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

ArticleView = Ember.View.extend(
  contentBinding: 'App.ArticlesController.selected'
  templateName: "templates_article"
  positionBinding: 'App.ArticlesController.selected.position'
  length: (->
    @content.length
  ).property('content')
  _letters: (->
     return @get 'content'.get('line')
  ).property()
  select: (event)->
    li = $(event.target).closest('li')
    if li.hasClass('active')
      li.removeClass('active')
    else
      li.addClass('active')
    
  move_left: ->
    console.log 'left p:' + @position
    console.log @get 'letters'
    @set 'position', @position - 1 if @position > 0
  move_right: ->
    console.log 'right p:' + @position
    @set 'position', @position + 1 

  search: (event) ->
    selection = $('ul#letters li.active').text()
    $.get "/dictionary/word/" + selection, (data) ->
      
      ResultsController.pushObject(
        Word.create(
          kanji: item[0]
          kana: item[1]
          desc: item[2]
          article_id: 1
        )
      ) for item in data


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
app.WordsController = WordsController
app.ArticlesController = ArticlesController
app.ResultsController = ResultsController
app.ResultView = ResultView
app.ArticlesList = ArticlesList
app.ArticleView = ArticleView
window.App = app
ArticlesController.sync()
WordsController.sync()
#chunks.append()
