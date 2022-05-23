class MorpherJS.Triangle extends MorpherJS.EventDispatcher
  p1: null
  p2: null
  p3: null
  
  constructor: (p1, p2, p3) ->
    @p1 = p1
    @p2 = p2
    @p3 = p3
    @p1.on 'remove', @remove
    @p2.on 'remove', @remove
    @p3.on 'remove', @remove

  # public methods

  remove: =>
    @trigger 'remove', this

  hasPoint: (p) =>
    @p1 is p || @p2 is p || @p3 is p

  clone: =>
    triangle = new MorpherJS.Triangle(@p1.clone(), @p2.clone(), @p3.clone())


  # transformations

  transform: (matrix) =>
    @p1.transform(matrix)
    @p2.transform(matrix)
    @p3.transform(matrix)
    
  getBounds: =>
    left = right = @p1.x
    top = bottom = @p1.y
    for p in [@p2, @p3]
      left = Math.min(left, p.x)
      right = Math.max(right, p.x)
      top = Math.min(top, p.y)
      bottom = Math.max(bottom, p.y)
    [left, top, right, bottom]

  getHeight: (pointNumber = 3) =>
    point = @["p#{pointNumber}"]

  visualize: (el, draggable = false) =>
    @p1.visualize(el, draggable)
    @p2.visualize(el, draggable)
    @p3.visualize(el, draggable)

  draw: (sourceBitmap, destinationCtx, destinationTriangle) =>    
    [left, top, right, bottom] = @getBounds()
    width = right-left
    height = bottom-top

    matr1 = new MorpherJS.Matrix()
    matr1.translate(-@p1.x, -@p1.y)
    matr1.rotate(-Math.atan2(@p2.y-@p1.y, @p2.x-@p1.x))
    from = @clone()
    from.transform(matr1.apply())

    matr2 = new MorpherJS.Matrix()
    rotation2 = Math.atan2(destinationTriangle.p2.y-destinationTriangle.p1.y, destinationTriangle.p2.x-destinationTriangle.p1.x)
    matr2.translate(-destinationTriangle.p1.x, -destinationTriangle.p1.y)
    matr2.rotate(-rotation2)
    to = destinationTriangle.clone()
    to.transform(matr2.apply())

    scaleX = to.p2.x / from.p2.x
    scaleY = to.p3.y / from.p3.y
    matr1.scale(scaleX, scaleY)
    state2 = @clone()
    state2.transform(matr1.apply())
    matr1.shear((to.p3.x-from.p3.x*scaleX) / (from.p3.y*scaleY))
    state3 = @clone()
    state3.transform(matr1.apply())
    matr1.rotate(rotation2)
    matr1.translate(destinationTriangle.p1.x, destinationTriangle.p1.y)

    destinationCtx.save()
    destinationCtx.setTransform.apply destinationCtx, matr1.apply(true).toTransform()
    
    points = []
    points.push @offset(@p1, @p2)
    points.push @offset(@p1, @p3)
    points.push @offset(@p2, @p3)
    points.push @offset(@p2, @p1)
    points.push @offset(@p3, @p1)
    points.push @offset(@p3, @p2)
    
    destinationCtx.beginPath()
    destinationCtx.moveTo points[0].x, points[0].y
    for point in points[1..-1]
      destinationCtx.lineTo point.x, point.y
    destinationCtx.closePath()
    destinationCtx.clip()
    if left < 0
      width += left
      left = 0
    if top < 0
      height += top
      top = 0
    excess = left + width - destinationCtx.canvas.width
    if excess > 0
      width -= excess
    excess = top + height - destinationCtx.canvas.height
    if excess > 0
      height -= excess
    excess = left + width - sourceBitmap.width
    if excess > 0
      width -= excess
    excess = top + height - sourceBitmap.height
    if excess > 0
      height -= excess
    if width < 0 or height < 0
      return
    destinationCtx.drawImage sourceBitmap, left, top, width, height, left, top, width, height

    destinationCtx.restore()
  
  offset: (p1, p2, distance = 0.7) =>
    # it's not the best solution, but better than nothing :)
    distance = 0 if window.chrome
    dx = p2.x - p1.x
    dy = p2.y - p1.y
    length = Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2))
    dx2 = dx * distance / length;
    dy2 = dy * distance / length;
    {x: p1.x - dx2, y: p1.y - dy2}