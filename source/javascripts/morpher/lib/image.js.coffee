class MorpherJS.Image extends MorpherJS.EventDispatcher
  el: null

  points: null
  triangles: null

  constructor: (json = {}) ->
    @el = new window.Image()
    @el.onload = @loadHandler
    @points = []
    @triangles = []
    @fromJSON json
    

  # setters & getters

  setSrc: (src) =>
    @el.src = src


  # points

  addPoint: (point, params = {}) =>
    unless point instanceof MorpherJS.Point
      point = new MorpherJS.Point point.x, point.y
    point.on "change", @changeHandler
    point.on 'remove', @removePoint
    @points.push point
    @trigger 'point:add', point, this unless params.silent
    point

  removePoint: (point, params = {}) =>
    if point instanceof MorpherJS.Point
      i = @points.indexOf point
    else
      i = point
    if i? && i != -1
      delete @points.splice i, 1
      @trigger 'point:remove', point, i, this unless params.silent

  makeCompatibleWith: (image) =>
    if @points.length != image.points.length
      console.warn "Incompatible mesh - number of the points should be equal" if console?
      if @points.length > image.points.length
        @points.splice image.points.length, @points.length-image.points.length
      else
        for point in image.points[(@points.length)..(image.points.length)]
          @addPoint x: point.x, y: point.y

  changeHandler: =>
    @trigger 'change'


  # triangles

  addTriangle: (p1, p2, p3) =>
    triangle = new MorpherJS.Triangle @points[p1], @points[p2], @points[p3]
    triangle.on 'remove', @removeTriangle
    @triangles.push triangle
    @trigger 'triangle:add', p1, p2, p3, triangle, this

  removeTriangle: (triangle, params = {})=>
    if triangle instanceof MorpherJS.Triangle
      i = @triangles.indexOf triangle
    else
      i = triangle
    if i? && i != -1
      delete @triangles.splice i, 1
      @trigger 'triangle:remove', triangle, i, this unless params.silent


  # image

  loadHandler: =>
    @trigger 'load', this, @el


  # JSON

  toJSON: =>
    json = {}
    json.points = []
    for point in @points
      json.points.push point.toJSON()
    json

  fromJSON: (json = {}, params = {}) =>
    @reset() if params.hard
    if json.points?
      for point, i in json.points
        if i > @points.length-1
          @addPoint point, params
        else
          @points[i].fromJSON point, params

  reset: =>
    for point in @points
      @removePoint point
