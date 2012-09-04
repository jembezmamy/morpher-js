class MorpherJS.Morpher extends MorpherJS.EventDispatcher
  images: null
  triangles: []
  canvas: null

  constructor: (params) ->
    @images = []
    @triangles = []
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
    image.on 'triangle:add', @addTriangleHandler
    image.on 'triangle:remove', @removeTriangleHandler
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
    for triangle in @triangles
      for v, k in triangle
        triangle[k] -= 1 if v >= index
    @trigger 'point:remove', this


  # triangles

  addTriangle: (i1, i2, i3) =>
    if @images.length > 0
      @images[0].addTriangle i1, i2, i3

  triangleExists: (i1, i2, i3) =>
    for t in @triangles
      if t.indexOf(i1) != -1 && t.indexOf(i2) != -1 && t.indexOf(i3) != -1
        return true
    false

  addTriangleHandler: (i1, i2, i3, triangle, image) =>
    if image.triangles.length > @triangles.length && !@triangleExists(i1, i2, i3)
      @triangles.push [i1, i2, i3]
    for img in @images
      if img.triangles.length < @triangles.length
        img.addTriangle i1, i2, i3
        return
    @trigger 'triangle:add', this

  removeTriangleHandler: (triangle, index, image) =>
    if image.triangles.length < @triangles.length
      delete @triangles.splice index, 1
    for img in @images
      if img.triangles.length > @triangles.length
        img.removeTriangle index
        return
    @trigger 'triangle:remove', this
    

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
    json.triangles = @triangles.slice()
    json


  fromJSON: (json = {}, params = {}) =>
    @reset() if params.hard
    if json.images?
      for image, i in json.images
        if i > @images.length - 1
          @addImage image, params
        else
          @images[i].fromJSON image, params
    if json.triangles?
      for triangle in json.triangles[@triangles.length..-1]
        @addTriangle triangle[0], triangle[1], triangle[2]
      

  reset: =>
    for image in @images
      @removeImage image
    @images = []


window.Morpher = MorpherJS.Morpher
