$ ->
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
    
  $("[data-resize]").each(->
    $this = $(this)
    url = $this.attr("src").match(/\/file\/(.*?)\//)[1]
    upscale = parseFloat($this.attr("data-resize"))
    width = parseInt($this.attr("src").match(/\&w\=(.*?)(\&|$)/)[1] * upscale)
    height = parseInt($this.attr("src").match(/\&h\=(.*?)(\&|$)/)[1] * upscale)
    filepicker_url = "https://www.filepicker.io/api/file/#{url}/convert?fit=crop&h=#{height}&w=#{width}"
    img = $("<img/>").attr("src", filepicker_url).load( ->
      $this.replaceWith(img)
    )
  )