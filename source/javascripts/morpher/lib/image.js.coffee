class MorpherJS.Image extends MorpherJS.EventDispatcher
  el: null
  source: null
  loaded: false

  mesh: null
  weight: 0
  x: 0
  y: 0
  

  constructor: (json = {}) ->
    @el = new window.Image()
    @el.onload = @loadHandler

    @source = document.createElement('canvas')
    
    @mesh = new MorpherJS.Mesh()
    @mesh.on 'all', @propagateMeshEvent
    @mesh.on 'change:bounds', @refreshSource
    
    @triangles = @mesh.triangles
    @points = @mesh.points
    @fromJSON json


  remove: =>
    @mesh.remove()
    @trigger 'remove', this 
    

  # setters & getters

  setSrc: (src) =>
    @loaded = false
    @el.src = src

  setWeight: (w, params = {}) =>
    @weight = w*1
    @trigger 'change:weight change' unless params.silent
  getWeight: =>
    @weight

  setX: (x, params = {}) =>
    @x = Math.round x*1
    @mesh.x = @x
    @trigger 'change:x change' unless params.silent
  getX: =>
    @x

  setY: (y, params = {}) =>
    @y =  Math.round y*1
    @mesh.y = @y
    @trigger 'change:y change' unless params.silent
  getY: =>
    @y

  moveTo: (x, y, params = {}) =>
    @setX(x, silent: true)
    @setY(y, silent: true)
    @trigger 'change:x change:y change' unless params.silent



  # image

  loadHandler: =>
    @loaded = true
    @refreshSource()
    @trigger 'load', this, @el


  # mesh proxy
  
  setMaxSize: =>
    @mesh.setMaxSize.apply this, arguments
  addPoint: =>
    @mesh.addPoint.apply this, arguments
  removePoint: =>
    @mesh.removePoint.apply this, arguments
  makeCompatibleWith: =>
    @mesh.makeCompatibleWith.apply this, arguments
  getRelativePositionOf: =>
    @mesh.getRelativePositionOf.apply this, arguments
  splitEdge: =>
    @mesh.splitEdge.apply this, arguments
  addTriangle: =>
    @mesh.addTriangle.apply this, arguments
  removeTriangle: =>
    @mesh.removeTriangle.apply this, arguments

  propagateMeshEvent: (type, target, args...) =>
    @trigger.apply this, [type, this].concat args


  # drawing

  draw: (ctx, mesh) =>
    for triangle, i in @triangles
      triangle.draw @source, ctx, mesh.triangles[i]

  refreshSource: =>
    return unless @loaded
    @source.width = @mesh.bounds.left + @mesh.bounds.width
    @source.height = @mesh.bounds.top + @mesh.bounds.height
    ctx = @source.getContext('2d')
    ctx.drawImage @el, 0, 0
    


  # JSON

  toJSON: =>
    json = @mesh.toJSON()
    json.src = @el.src
    json.x = @x
    json.y = @y
    json

  fromJSON: (json = {}, params = {}) =>
    @setX json.x, params if json.x?
    @setY json.y, params if json.y?
    @mesh.fromJSON(json, params)
    @setSrc json.src if json.src?
    
