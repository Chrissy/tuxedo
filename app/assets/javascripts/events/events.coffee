$ ->
  window.form = new Form('.autocomplete')
  window.search = new Search('.search')
    
  $("[data-resize]").each(->
    new Image($(this)).upscale()
  )

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
  
  $("[data-lazy-load]").each(->
    $.ajax(
      url: "/list/get/#{$(@).attr("data-lazy-load")}?start=#{$(this).find(".list-element").length}"
      success: (data) =>
        $(@).append(data)
    )
  )