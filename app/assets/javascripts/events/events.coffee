$ ->
  helpers = new Helpers
  
  window.form = new Form('.autocomplete')
  window.search = new Search('.search')

  $(".authenticate").each(->
    $this = $(this)
    $.get('/authenticate_before_render').promise().then((data) ->
      $this.addClass("authenticated") if Boolean(data)
    )
  )
  
  $("[bubble-on-focus]").not("focused").focus(->
    $target = $(this).closest($(this).attr("bubble-on-focus"))
    $target.addClass("focused")
    $(this).blur(->
      $target.removeClass("focused")
    )
  )
    
  helpers.setup_lazy_images()
