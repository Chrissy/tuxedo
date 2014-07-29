$ ->
  window.form = new Form('.autocomplete')
  window.search = new Search('.search')

  $(".authenticate").each(->
    $this = $(this)
    $.get('/authenticate_before_render').promise().then((data) ->
      $this.addClass("authenticated") if Boolean(data)
    )
  )
  
  #this is a temporary polyfill until webkit fixes a bug with swashes and first-letter
  $("h1, .swash").each( ->
    $(this).html($(this).html().replace(/^[^a-zA-Z]*([a-zA-Z])/g, '<span class="swash-cap">$1</span>'))
  )