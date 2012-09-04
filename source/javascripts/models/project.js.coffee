projectsStorage = new Backbone.LocalStorage("Projects")

class Gui.Models.Project extends Backbone.Model
  localStorage: projectsStorage

  images: null
  morpher: null

  constructor: ->
    @morpher = new Morpher()
    @morpher.on 'change image:add image:remove point:add point:remove triangle:add triangle:remove', @morpherChange
    
    @images = new Gui.Collections.Images()
    @images.bind 'add', @addImage
    @images.bind 'reset', @addAllImages
    @images.bind 'remove', @removeImage
    super
    
  initialize: (params) =>
    @setDefaultColor()
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

  addTriangle: (p1, p2, p3) =>
    @morpher.addTriangle p1, p2, p3


  morpherChange: =>
    @save morpher: @morpher.toJSON()
    

  initImagesStorage: =>
    @off 'sync', @initImagesStorage
    @images.localStorage = new Backbone.LocalStorage("Images#{@get('id')}")
    @images.fetch()

  addImage: (image, params = {}) =>
    @morpher.addImage image.morpherImage, params

  addAllImages: =>
    @addImage(image, silent: true) for image in @images.models
    @morpher.fromJSON @get('morpher'), hard: false, silent: true

  removeImage: (image, collection, params) =>
    @morpher.removeImage image.morpherImage
    


class Gui.Collections.Projects extends Backbone.Collection
  model: Gui.Models.Project
  localStorage: projectsStorage
