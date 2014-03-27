class window.Form
  constructor: (form) ->
    @form = $(form)

  getAllComponents: ->
    $.get("/components/all.json").then(
      (components) -> return components
      -> return console.log("components request failed")
    )
  
  setupMentions: ->
    self = @
    @getAllComponents().promise().then( (components) ->
      self.form.mention(
        delimiter: ":"
        users: components
      )
    )
    

