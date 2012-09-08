app = Ember.Application.create(
  title: "Hello" 
  articles: Ember.ArrayController.create(
    content: [
      title: "Title of article"
      text: "このたびは。大変お世話にな。りありがとう。ございました"
      content: "このたびは。大変お世話にな。りありがとう。ございました"
    
    ]
  )
)

BoxView = Ember.View.extend(
  templateName: "templates_demo"
  title: "adfadf"
  body: "this is body"
)

ParagraphView = Ember.View.extend(
    active: false
    isKanji: (-> 
      @content.match(/[\u4e00-\u9faf]+/)?
    ).property('content')
    tagName: "li"
    classNameBindings: ["active"]
    template: Ember.Handlebars.compile("<a>{{content}}</a>")
    click: ->
      #enable toogle only for kanji
      @toogle "active"  if @get("isKanji")
      $("body").append @content
    toogle: (key) ->
      if @get(key)
        @set key, false
      else
        @set key, true
)

SelectableParagraph = Ember.CollectionView.extend(
  textBinding: "App.articles.firstObject.text"
  tagName: "ul"
  classNames: "nav nav-pills"
  content: (->
    letters = @get("text") or "aaaaa"
    letters.match /([\u4e00-\u9faf]+)|([\u0000-\u4dff]*)/g
  ).property('text')

  itemViewClass: ParagraphView
)



SelectedChunk = Ember.CollectionView.extend(
  classNameBindings: ["hidden"]
  content: (->
    return []  if @text is `undefined`
    @getPath "text.letters"
  ).property("text")
  classNames: "nav nav-pills"
  tagName: "ul"
  itemViewClass: Ember.View.extend(
    tagName: "li"
    activeBinding: "content.active"
    classNameBindings: ["active"]
    template: Ember.Handlebars.compile("<a href='#'>{{content.content}}</a>")
    click: (event) ->
      @toogle "active"
      console.log @content.index + @content.chunk_start
  )
)

SelectableChunks = Ember.CollectionView.extend(
  articleBinding: "App.article.firstObject"
  # where chunk start in whole article
  content: (->
    if @article is `undefined` or @article.content is `undefined`
      []
    else
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

TextChunk = Ember.View.extend(
  active: false
  hidden: (->
    not @get("active")
  ).property("active")
  template: Ember.Handlebars.compile("{{view SelectedChunk textBinding=\"content\" hiddenBinding=\"hidden\"}} {{#if hidden}} {{content.content}} {{else}}<a class=\"btn\" href=\"#\" {{action search}}>Search</a>{{/if}}")
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
      result = Ember.ArrayController.create(content: $.map(eval_(data), (item) ->
        Model.Word.create
          kanji: item[0]
          kana: item[1]
          desc: item[2]
          article_id: App.data.articles.get("selected").id

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

#$("body").append("<div class=\"alert alert-info\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\">×</button>"+result_html+"</div>")

box = BoxView.create()
article = SelectableParagraph.create()
chunks = SelectableChunks.create()
box.append()
article.append()
chunks.append()
window.App = app