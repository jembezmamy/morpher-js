projectsStorage = new Backbone.LocalStorage("Projects")

class Gui.Models.Project extends Backbone.Model
  localStorage: projectsStorage

  images: null
    
  initialize: (params) =>
    @setDefaultColor()
    @images = new Gui.Collections.Images()
    if @isNew()
      @on 'sync', @initImagesStorage
    else
      @initImagesStorage()

  setDefaultColor: =>
    unless @get('color')
      rgb = hslToRgb(Math.random(), 0.4+Math.random()*0.3, 0.5+Math.random()*0.2)
      @set color: "rgb(#{rgb.join(', ')})"

  destroy: =>
    @images.each (image) =>
      image.destroy()
    super

  initImagesStorage: =>
    @off 'sync', @initImagesStorage
    @images.localStorage = new Backbone.LocalStorage("Images#{@get('id')}")
    @images.fetch()


class Gui.Collections.Projects extends Backbone.Collection
  model: Gui.Models.Project
  localStorage: projectsStorage
