$ ->
  window.form = new Form('.autocomplete')

  $(".authenticate").each(->
    $this = $(this)
    $.get('/authenticate_before_render').promise().then((data) ->
      $this.addClass("authenticated") if Boolean(data)
    )
  )

