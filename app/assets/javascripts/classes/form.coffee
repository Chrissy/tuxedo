class window.Form
  constructor: (form) ->
    @form = $(form)
    self = @
    @autocomplete = []
    @generateAutocomplete("/ingredients/all.json", ":") if @form.hasClass("components")
    @generateAutocomplete("/all.json", "=") if @form.hasClass("recipes")
    @generateAutocomplete("/list/all.json", "#") if @form.hasClass("lists")

  getElements: (url) ->
    $.get(url).then(
      (elements) -> return elements
    )

  generateAutocomplete: (url, flag) ->
    self = @
    @getElements(url).promise().then( (data) ->
      self.setupAutoComplete(data, flag)
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
