class window.Helpers
  setup_lazy_images: ->
    self = @
    $("[data-resize]").each(->
      new Image($(this))
    )
    
class window.Image
  constructor: ($image) ->
    @image = $image
    @src = $image.attr("src")
    @load_image()
    
  dimension: (name) ->
    upscale = parseFloat(@image.attr("data-resize"))
    d = @src.match(///\&#{name}\=(.*?)(\&|$)///)[1]
    increment: ->
      parseInt( d * upscale)
        
  increment_dimensions: ->
    @w = @dimension("w").increment()
    @h = @dimension("h").increment()
    
  filepicker_url: ->
    url = @image.attr("src").match(/\/file\/(.*?)\//)[1]
    d = @increment_dimensions()
    "https://www.filepicker.io/api/file/#{url}/convert?fit=crop&h=#{@h}&w=#{@w}"
      
  load_image: ->
    self = @
    img = $("<img/>").attr("src", @filepicker_url()).load( ->
      self.image.replaceWith(img)
    )

    
  