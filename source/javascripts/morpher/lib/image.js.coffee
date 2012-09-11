class MorpherJS.Image extends MorpherJS.EventDispatcher
  el: null

  mesh: null
  weight: 0

  constructor: (json = {}) ->
    @el = new window.Image()
    @el.onload = @loadHandler
    @mesh = new MorpherJS.Mesh()
    @mesh.on 'all', @propagateMeshEvent
    @triangles = @mesh.triangles
    @points = @mesh.points
    @fromJSON json
    

  # setters & getters

  setSrc: (src) =>
    @el.src = src

  setWeight: (w, params = {}) =>
    @weight = w*1
    @trigger 'change:weight' unless params.silent

  getWeight: =>
    @weight


  # image

  loadHandler: =>
    @trigger 'load', this, @el


  # mesh proxy

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
      triangle.draw @el, ctx, mesh.triangles[i]
    


  # JSON

  toJSON: =>
    json = @mesh.toJSON()
    json

  fromJSON: (json = {}, params = {}) =>
    @mesh.fromJSON(json, params)
      
