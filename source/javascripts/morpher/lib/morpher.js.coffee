class MorpherJS.Morpher extends MorpherJS.EventDispatcher
  images: null
  canvas: null

  constructor: (params) ->
    @images = []
    @canvas = document.createElement('canvas')
    

  # images

  addImage: (image, params = {}) =>
    unless image instanceof MorpherJS.Image
      image = new MorpherJS.Image(image)
    if @images.length
      image.makeCompatibleWith @images[@images.length-1]
    @images.push image
    image.on 'load', @loadHandler
    image.on 'change', @changeHandler
    image.on 'point:add', @addPointHandler
    image.on 'point:remove', @removePointHandler
    @loadHandler()
    @trigger 'image:add' unless params.silent

  removeImage: (image) =>
    i = @images.indexOf image
    if i != -1
      delete @images.splice i, 1
      @trigger 'image:remove'

  loadHandler: (e) =>
    @draw()
    for image in @images
      return false unless image.el.width && image.el.height
    @trigger 'load', this, @canvas

  changeHandler: (e) =>
    @trigger 'change'


  # points

  addPoint: (x, y) =>
    for image in @images
      image.addPoint x: x, y: y
    @trigger 'point:add', this

  addPointHandler: (point, image) =>
    for img in @images
      if img.points.length < image.points.length
        img.addPoint x: point.x, y: point.y
        return
    @trigger 'point:add', this

  removePointHandler: (point, index, image) =>
    for img in @images
      if img.points.length > image.points.length
        img.removePoint index
        return
    @trigger 'point:remove', this
    

  # drawing

  draw: =>
    @updateCanvasSize()

  updateCanvasSize: =>
    w = 0
    h = 0
    for image in @images
      w = Math.max image.el.width, w
      h = Math.max image.el.height, h
    if w != @canvas.width || h != @canvas.height
      @canvas.width = w
      @canvas.height = h
      @trigger 'resize', this, @canvas
    @trigger 'draw', this, @canvas


  # JSON

  toJSON: =>
    json = {}
    json.images = []
    for image in @images
      json.images.push image.toJSON()
    json


  fromJSON: (json = {}, params = {}) =>
    @reset() if params.hard
    if json.images?
      for image, i in json.images
        if i > @images.length - 1
          @addImage image, params
        else
          @images[i].fromJSON image, params
      

  reset: =>
    for image in @images
      @removeImage image
    @images = []


window.Morpher = MorpherJS.Morpher
