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
      flag = flag.text().trim()
      self.swapWithComponentLink(query, flag)
      self.addToComponentList(flag)
    );

  swapWithComponentLink: (query, flag) ->
    pretext = @form.val().substring(0, query.pos)
    aftertext = @form.val().substring(query.pos + flag.length)
    newstr = "#{pretext}[#{flag}] #{aftertext}"
    @form.val(newstr)

  addToComponentList: (flag) ->
    components = @form.siblings("#components")
    components.val(components.text() << flag << ",")

    

