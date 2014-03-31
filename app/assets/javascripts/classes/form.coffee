class window.Form
  constructor: (form) ->
    @form = $(form)
    self = @
    @getAllComponents().promise().then( (data) ->
      self.components = self.setupBloodhound(data)
      self.components.initialize()
      self.setupTypeahead(@components)
    )

  getAllComponents: ->
    $.get("/components/all.json").then(
      (components) -> return components
      -> return console.log("components request failed")
    )

  setupBloodhound: (storedData) ->
    return new Bloodhound(
      name: "components"
      local: storedData
      datumTokenizer: (d) ->
        return Bloodhound.tokenizers.whitespace(d.username);
      queryTokenizer: Bloodhound.tokenizers.whitespace
    )

  setupTypeahead: ->
    $('#prefetch .typeahead').typeahead(
      hint: true,
      highlight: true, 
      minLength: 1
    ,
      name: 'components',
      displayKey: 'username',
      source: @components.ttAdapter()
    );

    

