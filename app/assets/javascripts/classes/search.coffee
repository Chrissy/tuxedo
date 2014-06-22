class window.Search
  constructor: (input) ->
    self = @
    @input = input
    @get().promise().then((data) ->
      bloodhound_instance = self.build_bloodhound(data)
      bloodhound_instance.initialize()
      self.build_typeahead(bloodhound_instance)
    )
    
  build_bloodhound: (data) ->
    return new Bloodhound({
      name: 'recipes',
      local: data,
      datumTokenizer: (d) ->
        return Bloodhound.tokenizers.whitespace(d.val)
      queryTokenizer: Bloodhound.tokenizers.whitespace
      })
      
  build_typeahead: (bloodhound_instance) ->
    $(@input).typeahead(null, {
      source: bloodhound_instance.ttAdapter()
      highlight: false,
      hint: false,
      minLength: 2,
      name: 'recipes',
      displayKey: 'val',
    });
    
  get: ->
    $.get("/search.json").then( 
      (data) -> return $.makeArray(data)
    )