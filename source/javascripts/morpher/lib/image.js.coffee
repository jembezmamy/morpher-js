class MorpherJS.Image extends MorpherJS.EventDispatcher
  el: null
  source: null

  mesh: null
  weight: 0
  

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
    
    

  # setters & getters

  setSrc: (src) =>
    @el.src = src

  setWeight: (w, params = {}) =>
    @weight = w*1
    @trigger 'change:weight change' unless params.silent

  getWeight: =>
    @weight


  # image

  loadHandler: =>
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
    @source.width = @mesh.bounds.width
    @source.height = @mesh.bounds.height
    ctx = @source.getContext('2d')
    ctx.drawImage @el, 0, 0
    


  # JSON

  toJSON: =>
    json = @mesh.toJSON()
    json.src = @el.src
    json

  fromJSON: (json = {}, params = {}) =>
    @mesh.fromJSON(json, params)
    @el.src = json.src if json.src?
      
