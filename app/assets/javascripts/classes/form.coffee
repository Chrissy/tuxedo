class window.Form
  constructor: (form) ->
    @form = $(form).first()
    self = @
    @autocomplete = []
    @getAllComponents().promise().then( (data) ->
      self.setupAutoComplete(data, ":")
    )
    @getAllRecipes().promise().then( (data) ->
      self.setupAutoComplete(data, "=")
    )

  getAllComponents: ->
    $.get("/components/all.json").then(
      (components) -> return components
      -> return console.log("components request failed")
    )

  getAllRecipes: ->
    $.get("/all.json").then(
      (recipes) -> return recipes
      -> return console.log("recipes request failed")
    )

  setupAutoComplete: (data, flag) ->
    self = @
    @autocomplete[flag] = @form.atwho({
      at: flag,
      data: data
    }).on("inserted.atwho", (event, flag, query) ->
      flag = flag.text().trim()
      self.swapWithComponentLink(query, flag)
    );

  swapWithComponentLink: (query, flag) ->
    pretext = @form.val().substring(0, query.pos)
    aftertext = @form.val().substring(query.pos + flag.length + 2)
    newstr = "#{pretext}[#{flag}] #{aftertext}"
    @form.val(newstr)

    

