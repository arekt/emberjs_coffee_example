Article = Ember.Object.extend(
  title: "Title of article"
  text: "このたびは。大変お世話にな。りありがとう。ございました"
  content: "このたびは。大変お世話にな。りありがとう。ございました"
)

Word = Ember.Object.extend(
  kanji : ""
  kana :""
  description : ""
  save : ->
    word =  
      word:  
        id: @id || null
        kanji:@kanji
        kana:@kana
        desc:@desc
        article_id:@article_id
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
      
      #App.data.news.selected.set('content',data)
      result = Ember.ArrayController.create(content: $.map(data, (item) ->
        Word.create
          kanji: item[0]
          kana: item[1]
          desc: item[2]
          article_id: 1

      ))
      
      #make some button to select word and then add word to words collection
      #App.data.articles.get('selected').words.push(result.get('firstObject'))
      view = Ember.View.create(
        layout: Ember.Handlebars.compile("<div class=\"alert alert-info\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\">×</button>{{yield}}</div>")
        template: Ember.Handlebars.compile("{{#each result}}              <h3>{{this.kanji}}{{this.kana}}</h3>              <p>{{this.desc}}</p>              <a class='btn' {{action  add }}>Add</a>              {{/each}}")
        result: result
        add: (event) ->
          word = event.context
          word.save()
          App.data.articles.get("selected").words.pushObject word
          @remove() # remove view from DOM
      )
      view.append "body"
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
#chunks.append()
window.App = app