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
    @images.bind 'change:targetWeight', @weightHandler
    super
    
  initialize: (params) =>
    @setDefaultColor()
    
    if @isNew()
      @on 'sync', @initImagesStorage
    else
      @initImagesStorage()

    @on 'change:blend_function', @updateBlendFunction
    @updateBlendFunction()
    

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


  updateBlendFunction: =>
    eval("f = " + @get('blend_function'))
    @morpher.blendFunction = f if f?
    @morpher.draw()

  morpherChange: =>
    @save morpher: @morpher.toJSON(), {silent: true}

  getCode: =>
    json = @morpher.toJSON()
    for img, i in json.images
      img.src = @images.models[i].get('url')
    JSON.stringify json

  weightHandler: (image) =>
    totalW = 0
    for img in @images.models
      totalW += img.get('targetWeight') if img isnt image
    defaultW = if totalW > 0 then 0 else 1
    maxW = (1-image.get('targetWeight')) / (totalW || @images.models.length-1)
    for img in @images.models
      unless img is image
        img.set weight: (defaultW || img.get('targetWeight')) * maxW
    

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
