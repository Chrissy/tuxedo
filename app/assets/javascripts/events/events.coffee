$ ->
  window.form = new Form('.autocomplete')
  window.search = new Search('.search')
    
  upscale_all_images = ->    
    $("[data-resize]").each(->
      new Image($(this)).upscale()
    )
  upscale_all_images()
  
  $("[bubble-on-focus]").not("focused").focus(->
    $target = $(this).closest($(this).attr("bubble-on-focus"))
    $target.addClass("focused")
    $(this).blur(->
      $target.removeClass("focused")
    )
  )
  
  # $("[data-lazy-load]").each(->
  #   $.ajax(
  #     url: "/list/get/#{$(@).attr("data-lazy-load")}?start=#{$(this).find(".list-element").length}"
  #     success: (data) =>
  #       $(@).append(data)
  #       upscale_all_images()
  #   )
  # )
  
  $(".clear_image").on("click", ->
    $(this).addClass("cleared").parent().find('[type="filepicker"]').attr("value", "")
    return false
  )
  
  $(".show-extra-options").on("click", ->
    $(this).siblings(".extra-options").toggle()
  )
  
  $("div[href]").on("click", ->
    window.location = $(this).attr("href")
  )
  
  toggleSocialPrompt = => $(".social-prompt").toggleClass("active")
  window.setTimeout(toggleSocialPrompt, 1000)
  window.setTimeout(toggleSocialPrompt, 4000)
  