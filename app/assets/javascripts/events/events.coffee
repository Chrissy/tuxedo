$ ->
  window.form = new Form('.autocomplete')
  window.search = new Search('.search')

  $(".authenticate").each(->
    $this = $(this)
    $.get('/authenticate_before_render').promise().then((data) ->
      $this.addClass("authenticated") if Boolean(data)
    )
  )