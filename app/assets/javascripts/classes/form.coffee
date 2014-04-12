class window.Form
  constructor: (form) ->
    @form = $(form)
    self = @
    @getAllComponents().promise().then( (data) ->
      self.setupAutoComplete(data)
    )

  getAllComponents: ->
    $.get("/components/all.json").then(
      (components) -> return components
      -> return console.log("components request failed")
    )

  setupAutoComplete: (data) ->
    self = @
    @autocomplete = @form.atwho({
      at: ":",
      data: data
    }).on("inserted.atwho", (event, flag, query) ->
      self.swapWithComponentLink(query, flag)
    );

  swapWithComponentLink: (query, flag) ->
    text = flag.text().trim()
    pretext = @form.val().substring(0, query.pos)
    aftertext = @form.val().substring(query.pos + text.length)
    newstr = "#{pretext}[#{text}] #{aftertext}"
    @form.val(newstr)

    

