class window.Helpers
  
  find_param: (name, string) ->
    return string.match(///\&#{name}\=(.*?)(\&|$)///)[1]
      
  setup_lazy_images: ->
    self = @
    $("[data-resize]").each(->
      $this = $(this)
      src = $this.attr("src")
      upscale = parseFloat($this.attr("data-resize"))
      url = $this.attr("src").match(/\/file\/(.*?)\//)[1]
      width = parseInt(self.find_param("w", src) * upscale)
      height = parseInt(self.find_param("h", src) * upscale)
      filepicker_url = "https://www.filepicker.io/api/file/#{url}/convert?fit=crop&h=#{height}&w=#{width}"
      img = $("<img/>").attr("src", filepicker_url).load( ->
        $this.replaceWith(img)
      )
    )
    