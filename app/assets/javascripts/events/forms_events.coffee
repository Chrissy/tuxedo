$ ->
  window.form = new Form('.autocomplete')

  $(".authenticate").each(->
    $this = $(this)
    $.get('/authenticate_before_render').promise().then((data) ->
      $this.addClass("authenticated") if Boolean(data)
    )
  )
  
  build = (data) ->
    engine = new Bloodhound({
      name: 'recipes',
      local: data,
      datumTokenizer: (d) ->
        return Bloodhound.tokenizers.whitespace(d.val)
      queryTokenizer: Bloodhound.tokenizers.whitespace
      });
    
    engine.initialize()
      
    $('.search').typeahead(null, {
      source: engine.ttAdapter()
      highlight: false,
      hint: false,
      minLength: 3,
      name: 'recipes',
      displayKey: 'val',
    });
    
  $.get("/search.json").then( (data) ->
    build($.makeArray(data))
  )