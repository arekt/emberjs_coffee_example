Article = Ember.Object.extend(
  title: "Title of article"
  text: "このたびは。大変お世話にな。りありがとう。ございました"
  content: "近世の朝鮮王朝
講師：東京大学准教授　六反田 豊
ゲスト：ヒョンギ
語り：森川智之

14 世紀末、朝鮮半島では李成桂が高麗を滅ぼして朝鮮王朝を建国し、仏教にかわって儒学、とくにそのなかでも朱子学を重視し、学問や独自の文化を発展させた。16 世紀末には豊臣秀吉の軍事侵入で大きな被害を受けたが、一時断絶していた日本との国交が17 世紀初めに回復すると、以後260 年ほどの間、平和的な関係を維持した。この期間に12 回にわたって朝鮮から日本へ派遣された朝鮮国王の使節、通信使に焦点を合わせ、日本との関係を中心にして朝鮮王朝の歴史をみていく。"
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
  title: "Hello" 
  articles: Ember.ArrayController.create(
    content: [ Article.create() ]
  )
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
  active: false
  hidden: (->
    not @get("active")
  ).property("active")
  templateName: "templates_text_chunk" 
  click: (event) ->
    unless @get("active")
      @getPath("parentView.childViews").setEach "active", false
      @set "active", true
      console.log "setting " + this + "to active state"

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

SelectableChunks = Ember.CollectionView.extend(
  articleBinding: "App.articles.firstObject"
  # where chunk start in whole article
  content: (->
    if @article is `undefined` or @article.content is `undefined`
      ['aa','b']
    else
      console.log('computing chunks')
      chunks = @getPath("article.content").match(/([^,.、。]+)([,.、。]+)/g)
      return []  unless chunks
      object_chunks = []
      position = 0
      chunks.forEach (item, index, self) ->
        chunk = Ember.Object.create(
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
      @get("article").set "chunks", object_chunks
      console.log @get("article")
      object_chunks
  ).property("article")
  itemViewClass: TextChunk
)


#$("body").append("<div class=\"alert alert-info\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\">×</button>"+result_html+"</div>")
app.SelectableChunks =  SelectableChunks
app.SelectedChunkView = SelectedChunkView
app.WordsController = WordsController
app.ResultsController = ResultsController
app.ResultView = ResultView
WordsController.sync()
#chunks.append()
window.App = app