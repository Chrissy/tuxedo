class window.Image
  constructor: ($image) ->
    @image = $image
    @src = $image.attr("src")
    
  resize: ->
    @rez = @rez || parseFloat(@image.attr("data-resize"))
    
  dimension: (name) ->
    dimension = @src.match(///\&#{name}\=(.*?)(\&|$)///)[1]
    self = @
    increment: ->
      parseInt(dimension * self.resize())
    
  filepicker_url: ->
    url = @src.match(/\/file\/(.*?)\//)[1]
    compression = if @image.attr("data-dont-compress") then "100" else "60"
    "https://www.filepicker.io/api/file/#{url}/convert?fit=crop&format=jpg&quality=#{compression}&h=#{@dimension("h").increment()}&w=#{@dimension("w").increment()}&cache=true"
      
  upscale: ->
    self = @
    img = self.image.clone().attr("src", @filepicker_url()).load( ->
      self.image.replaceWith(img)
    )

    
  