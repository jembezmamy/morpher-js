class MorpherJS.Triangle extends Backbone.Model
  p1: null
  p2: null
  p3: null
#  source: null
#  element: null
#  destination: null
  
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


#  clone: =>
#    triangle = new MorpherJS.Triangle(@p1.clone(), @p2.clone(), @p3.clone())

#  transform: (matrix) =>
#    @p1.transform(matrix)
#    @p2.transform(matrix)
#    @p3.transform(matrix)

#  setPoint: (index, point) =>
#    @["p#{index}"] = point
#    point.bind 'change', @changeHandler

#  hasPoint: (p) =>
#    @p1 is p || @p2 is p || @p3 is p

#  getBounds: =>
#    left = right = @p1.x
#    top = bottom = @p1.y
#    for p in [@p2, @p3]
#      left = Math.min(left, p.x)
#      right = Math.max(right, p.x)
#      top = Math.min(top, p.y)
#      bottom = Math.max(bottom, p.y)
#    [left, top, right, bottom]

#  getHeight: (pointNumber = 3) =>
#    point = @["p#{pointNumber}"]

#  visualize: (el, draggable = false) =>
#    @p1.visualize(el, draggable)
#    @p2.visualize(el, draggable)
#    @p3.visualize(el, draggable)

#  draw: (sourceBitmap, destinationParent, destinationTriangle) =>
#    @source = sourceBitmap
#    @element = $('<canvas />').appendTo(destinationParent)
#    @element.css transformOrigin: "0 0"
#    @destination = destinationTriangle
#    @destination.bind 'change', @changeHandler
#    @redraw()
#    

#  redraw: =>
#    [left, top, right, bottom] = @getBounds()
#    origin = 
#      x: @p1.x - left,
#      y: @p1.y - top
#    width = right-left
#    height = bottom-top
#    
#    @element.attr width: width, height: height
#    ctx = @element.get(0).getContext('2d')
#    ctx.beginPath()
#    ctx.moveTo(@p1.x-left, @p1.y-top)
#    ctx.lineTo(@p2.x-left, @p2.y-top)
#    ctx.lineTo(@p3.x-left, @p3.y-top)
#    ctx.closePath()
#    ctx.clip()
#    ctx.drawImage @source, left, top, width, height, 0, 0, width, height

#    matr1 = new MorpherJS.Matrix()
#    matr1.translate(-@p1.x, -@p1.y)
#    matr1.rotate(-Math.atan2(@p2.y-@p1.y, @p2.x-@p1.x))
#    from = @clone()
#    from.transform(matr1.apply())

#    matr2 = new MorpherJS.Matrix()
#    rotation2 = Math.atan2(@destination.p2.y-@destination.p1.y, @destination.p2.x-@destination.p1.x)
#    matr2.translate(-@destination.p1.x, -@destination.p1.y)
#    matr2.rotate(-rotation2)
#    to = @destination.clone()
#    to.transform(matr2.apply())

#    scaleX = to.p2.x/from.p2.x
#    scaleY = to.p3.y/from.p3.y
#    matr1.scale(scaleX, scaleY)
#    state2 = @clone()
#    state2.transform(matr1.apply())
#    matr1.shear((to.p3.x-from.p3.x*scaleX)/(from.p3.y*scaleY))
#    state3 = @clone()
#    state3.transform(matr1.apply())
#    matr1.rotate(rotation2)
#    matr1.translate(@destination.p1.x, @destination.p1.y)

#    matr1.removeTransform(0)
#    matr1.translate(-origin.x, -origin.y)
#    
#    @element.css
#      transform: matr1.apply().toCSS(),
#      transformOrigin: "#{origin.x}px #{origin.y}px"

#  changeHandler: (target) =>
#    @trigger 'change', this unless target is @destination
#    @redraw() if @element?
