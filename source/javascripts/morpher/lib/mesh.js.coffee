class MorpherJS.Mesh extends MorpherJS.EventDispatcher
  points: null
  triangles: null
  bounds: {width: 0, height: 0}

  maxWidth: 0
  maxHeight: 0
  x: 0
  y: 0
  
  constructor: (params = {}) ->
    @points = []
    @triangles = []

  # bounds

  setMaxSize: (w, h) =>
    @maxWidth = w
    @maxHeight = h

  refreshBounds: (params = {})=>
    bounds = {width: 0, height: 0}
    for point in @points
      bounds.width = Math.max bounds.width, point.x
      bounds.height = Math.max bounds.height, point.y
    if bounds.width != @bounds.width || bounds.height != @bounds.height
      @bounds = bounds
      @trigger 'change:bounds' unless params.silent

  # points

  addPoint: (pointParams, params = {}) =>
    unless pointParams instanceof MorpherJS.Point
      if pointParams.points?
        position = @resolveRelativePosition(pointParams)
      else
        position = pointParams
        pointParams = null
      point = new MorpherJS.Point position.x, position.y, {mesh: this}
    else
      point = pointParams
      point.mesh = this
      pointParams = null
    point.on "change", @changeHandler
    point.on 'remove', @removePoint
    @points.push point
    @refreshBounds(params)
    @trigger 'point:add', this, point, pointParams unless params.silent
    point

  removePoint: (point, params = {}) =>
    if point instanceof MorpherJS.Point
      i = @points.indexOf point
    else
      i = point
    if i? && i != -1
      delete @points.splice i, 1
      @trigger 'point:remove', this, point, i unless params.silent

  makeCompatibleWith: (mesh) =>
    if mesh instanceof MorpherJS.Image
      mesh = mesh.mesh
    if @points.length != mesh.points.length
      if @points.length > mesh.points.length
        @points.splice mesh.points.length, @points.length-mesh.points.length
      else
        for point in mesh.points[(@points.length)..(mesh.points.length)]
          @addPoint x: point.x, y: point.y

  changeHandler: =>
    @refreshBounds()
    @trigger 'change'


  # relative position

  getRelativePositionOf: (point) =>
    # TODO it would be better to find nearest edges instead of points
    nearest = []
    for p in @points
      unless p is point
        d = p.distanceTo(point)
        if nearest.length == 0
          nearest.push {distance: d, point: p}
        else
          for n, i in nearest
            if d < n.distance || (i == nearest.length-1 && nearest.length < 3)
              obj = {distance: d, point: p}
              if nearest.length >= 3
                nearest.splice i, 1, obj
              else if d < n.distance
                nearest.splice i, 0, obj
              else
                nearest.splice i+1, 0, obj
              break
    x = y = 0
    switch nearest.length
      when 0
        x = point.x
        y = point.y
      when 1
        x = point.x - nearest[0].point.x
        y = point.y - nearest[0].point.y
      when 2, 3
        [a, b] = @findLine(nearest[0].point, nearest[1].point)
        if nearest.length == 2
          intersection = @findNearestPointOfLine(a, b, point)
        else
          [a2, b2] = @findLine(point, nearest[2].point)
          # TODO special procedure for parallel lines (a == a2)
          iX = (b2 - b) / (a - a2)
          iY = a*iX + b
          intersection = new MorpherJS.Point iX, iY
        baseD = nearest[0].point.distanceTo nearest[1].point
        directionX = if (intersection.x - nearest[0].point.x) * (nearest[1].point.x - nearest[0].point.x) > 0 then 1 else -1
        dX = nearest[0].point.distanceTo intersection
        x = dX * directionX / baseD
        dY = point.distanceTo intersection
        if nearest.length == 2
          directionY = if (point.y - intersection.y) * (nearest[1].point.x - nearest[0].point.x) < 0 then 1 else -1
        else
          baseD = nearest[2].point.distanceTo intersection
          directionY = if (point.x - intersection.x) * (nearest[2].point.x - intersection.x) > 0 then 1 else -1
        y = dY * directionY / baseD
        
    nearest = (@points.indexOf(n.point) for n in nearest)
    {points: nearest, x: x, y: y}

  resolveRelativePosition: (position) =>
    switch position.points.length
      when 0
        x = position.x
        y = position.y
      when 1
        point = @points[position.points[0]]
        x = point.x + position.x
        y = point.y + position.y
      when 2, 3
        point1 = @points[position.points[0]]
        point2 = @points[position.points[1]]
        iX = (point2.x - point1.x)*position.x + point1.x
        iY = (point2.y - point1.y)*position.x + point1.y
        intersection = new MorpherJS.Point iX, iY
        if position.points.length == 2
          dX = (point2.y - point1.y)*position.y
          dY = -(point2.x - point1.x)*position.y
        else
          point3 = @points[position.points[2]]
          dX = (point3.x - intersection.x)*position.y
          dY = (point3.y - intersection.y)*position.y
        x = intersection.x + dX
        y = intersection.y + dY
    {x: x, y: y}

  findLine: (p1, p2) =>
    if p1.x - p2.x
      a = (p1.y - p2.y) / (p1.x - p2.x)
      b = p1.y - a*p1.x 
      [a, b]
    else # vertical line
      [null, p1.x]

  findNearestPointOfLine: (a, b, p) =>
    if a?
      normalA = -1/a
      normalB = p.y - normalA*p.x
      x = (normalB-b)/(a-normalA)
      y = a*x + b
    else # vertical line
      x = b
      y = p.y
    new MorpherJS.Point x, y
    


  # edges

  splitEdge: (p1, p2) =>
    i1 = @points.indexOf p1
    i2 = @points.indexOf p2
    p4 = @addPoint points: [i1, i2], x: 0.5, y: 0
    i4 = @points.indexOf p4
    i = 0
    while i < @triangles.length
      triangle = @triangles[i]
      if triangle.hasPoint(p1) && triangle.hasPoint(p2)
        p3 = point for point in [triangle.p1, triangle.p2, triangle.p3] when point != p1 && point != p2
        i3 = @points.indexOf p3
        triangle.remove()
        @addTriangle(i1, i3, i4)
        @addTriangle(i2, i3, i4)
      else
        i++
        


  # triangles

  addTriangle: (p1, p2, p3) =>
    return unless @points[p1] && @points[p2] && @points[p3]
    triangle = new MorpherJS.Triangle @points[p1], @points[p2], @points[p3]
    triangle.on 'remove', @removeTriangle
    @triangles.push triangle
    @trigger 'triangle:add', this, p1, p2, p3, triangle

  removeTriangle: (triangle, params = {}) =>
    if triangle instanceof MorpherJS.Triangle
      i = @triangles.indexOf triangle
    else
      i = triangle
      triangle = @triangles[i]
    if i? && i != -1
      delete @triangles.splice i, 1
      triangle.off 'remove', @removeTriangle
      triangle.remove()
      @trigger 'triangle:remove', this, triangle, i unless params.silent


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
