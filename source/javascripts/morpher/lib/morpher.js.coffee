class MorpherJS.Morpher extends MorpherJS.EventDispatcher
  images: null
  triangles: []
  mesh: null
  
  canvas: null
  ctx: null
  tmpCanvas: null
  tmpCtx: null

  blendFunction: null
  finalTouchFunction: null
  easingFunction: null

  requestID: null
  
  t0: null
  duration: null
  state0: null
  state1: null
  state: null

  constructor: (params = {}) ->
    @images = []
    @triangles = []
    @mesh = new MorpherJS.Mesh()
    
    @canvas = document.createElement('canvas')
    @ctx = @canvas.getContext('2d')
    @tmpCanvas = document.createElement('canvas')
    @tmpCtx = @tmpCanvas.getContext('2d')
    
    @fromJSON params
    @set [1]


  set: (weights, params = {}) =>
    @state = []
    for img, i in @images
      w = weights[i] || 0
      @state.push w
      img.setWeight w, params
      
  get: =>
    @state.slice()

  animate: (weights, duration, easing) =>
    @state0 = []
    for img in @images
      @state0.push img.getWeight()
    @state1 = weights
    @t0 = new Date().getTime()
    @duration = duration
    @easingFunction = easing
    @trigger "animation:start", this
    @draw()
    

  # images

  imageEvents:
    'load'            : "loadHandler"
    'change'          : "changeHandler"
    'point:add'       : "addPointHandler"
    'point:remove'    : "removePointHandler"
    'triangle:add'    : "addTriangleHandler"
    'triangle:remove' : "removeTriangleHandler"
    'remove'          : "removeImage"

  addImage: (image, params = {}) =>
    unless image instanceof MorpherJS.Image
      image = new MorpherJS.Image(image)
    image.remove()
    if @images.length
      image.makeCompatibleWith @mesh
    else
      @mesh.makeCompatibleWith image
    @images.push image
    for event, handler of @imageEvents
      image.on event, @[handler]
    @loadHandler()
    @trigger 'image:add' this, image unless params.silent

  removeImage: (image) =>
    i = @images.indexOf image
    for event, handler of @imageEvents
      image.off event, @[handler]
    if i != -1
      delete @images.splice i, 1
      @trigger 'image:remove' this, image

  loadHandler: (e) =>
    @draw()
    for image in @images
      return false unless image.loaded
    @refreshMaxSize()
    @trigger 'load', this, @canvas

  changeHandler: (e) =>
    @draw()
    @trigger 'change', this


  # points

  addPoint: (x, y) =>
    for image in @images.concat @mesh
      image.addPoint x: x, y: y
    @trigger 'point:add', this

  addPointHandler: (image, point, pointParams = null) =>
    position = pointParams || image.getRelativePositionOf(point)
    for img in @images
      if img.points.length < image.points.length
        img.addPoint position
        return
    if @mesh.points.length < image.points.length
      @mesh.addPoint position
      @trigger 'point:add', this

  removePointHandler: (image, point, index) =>
    for img in @images
      if img.points.length > image.points.length
        img.removePoint index
        return
    if @mesh.points.length > image.points.length
      @mesh.removePoint index
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

  addTriangleHandler: (image, i1, i2, i3, triangle) =>
    if image.triangles.length > @triangles.length && !@triangleExists(i1, i2, i3)
      @triangles.push [i1, i2, i3]
    for img in @images
      if img.triangles.length < @triangles.length
        img.addTriangle i1, i2, i3
        return
    if @mesh.triangles.length < @triangles.length
      @mesh.addTriangle i1, i2, i3
    @trigger 'triangle:add', this

  removeTriangleHandler: (image, triangle, index) =>
    if image.triangles.length < @triangles.length
      delete @triangles.splice index, 1
    for img in @images
      if img.triangles.length > @triangles.length
        img.removeTriangle index
        return
    if @mesh.triangles.length > @triangles.length
      @mesh.removeTriangle index
    @trigger 'triangle:remove', this
    

  # drawing

  draw: =>
    return if @requestID?
    requestFrame = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.msRequestAnimationFrame || window.oRequestAnimationFrame || window.webkitRequestAnimationFrame
    if requestFrame?
      @requestID = requestFrame @drawNow
    else
      @drawNow()

  drawNow: =>
    @canvas.width = @canvas.width
    @updateCanvasSize()
    @animationStep()
    @updateMesh()
    blend = @blendFunction || MorpherJS.Morpher.defaultBlendFunction
    if @canvas.width > 0 && @canvas.height > 0
      sortedImages = @images.slice().sort (a, b) ->
        b.weight - a.weight
      for image in sortedImages
        @tmpCanvas.width = @tmpCanvas.width
        image.draw @tmpCtx, @mesh
        blend @canvas, @tmpCanvas, image.weight
      @finalTouchFunction(@canvas) if @finalTouchFunction?
      @trigger 'draw', this, @canvas
    @requestID = null
    @draw() if @t0?

  updateCanvasSize: =>
    w = 0
    h = 0
    for image in @images
      w = Math.max image.el.width+image.getX(), w
      h = Math.max image.el.height+image.getY(), h
    if w != @canvas.width || h != @canvas.height
      @canvas.width = @tmpCanvas.width = w
      @canvas.height = @tmpCanvas.height = h
      @refreshMaxSize()
      @trigger 'resize', this, @canvas

  refreshMaxSize: =>
    for img in @images
      img.setMaxSize(@canvas.width, @canvas.height)

  updateMesh: =>
    x0 = @canvas.width / 2
    y0 = @canvas.height / 2
    for p, i in @mesh.points
      p.x = x0
      p.y = y0
      for img in @images
        p.x += (img.getX()+img.points[i].x-x0)*img.weight
        p.y += (img.getY()+img.points[i].y-y0)*img.weight

  animationStep: =>
    if @t0?
      t = new Date().getTime() - @t0
      if t >= @duration
        state = @state1
        @state0 = @state1 = @t0 = null
        @trigger "animation:complete", this
      else
        progress = t / @duration
        progress = @easingFunction(progress) if @easingFunction?
        state = []
        for w, i in @state0
          state.push w*(1-progress) + @state1[i]*progress
      @set state, {silent: true}

  @defaultBlendFunction: (destination, source, weight) =>
    dData = destination.getContext('2d').getImageData(0, 0, source.width, source.height)
    sData = source.getContext('2d').getImageData(0, 0, source.width, source.height)
    for value, i in sData.data
      dData.data[i] += value*weight
    destination.getContext('2d').putImageData dData, 0, 0


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
    if json.blendFunction?
      @blendFunction = json.blendFunction
    if json.images?
      for image, i in json.images
        if i > @images.length - 1
          @addImage image, params
        else
          @images[i].fromJSON image, params
      @mesh.makeCompatibleWith(@images[0])
    if json.triangles?
      for triangle in json.triangles[@triangles.length..-1]
        @addTriangle triangle[0], triangle[1], triangle[2]
      

  reset: =>
    for image in @images
      @removeImage image
    @images = []


window.Morpher = MorpherJS.Morpher
