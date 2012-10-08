class MorpherJS.Point extends MorpherJS.EventDispatcher
  x: 0
  y: 0
  mesh: null

  constructor: (x, y, params = {}) ->
    @mesh = params.mesh if params.mesh?
    @setX x, silent: true
    @setY y, silent: true
    

  # getters & setters

  getX: =>
    @x
  setX: (x, params = {}) =>
    x = Math.max -@mesh.x, Math.min @mesh.maxWidth-@mesh.x, x if @mesh? && @mesh.maxWidth
    unless @x == x
      @x = x
      @trigger 'change:x change', this unless params.silent

  getY: =>
    @y
  setY: (y, params = {}) =>
    y = Math.max -@mesh.y, Math.min @mesh.maxHeight-@mesh.y, y if @mesh? && @mesh.maxHeight
    unless @y == y
      @y = y
      @trigger 'change:y change', this unless params.silent

      
  # public methods

  remove: =>
    @trigger 'remove', this

  clone: =>
    new MorpherJS.Point(@x, @y)

  distanceTo: (point) =>
    Math.sqrt(Math.pow(point.x-@x, 2) + Math.pow(point.y-@y, 2))

  transform: (matrix) =>
    tmpX = matrix.get(0,0)*@x + matrix.get(0,1)*@y + matrix.get(0,2)
    tmpY = matrix.get(1,0)*@x + matrix.get(1,1)*@y + matrix.get(1,2)
    @x = tmpX
    @y = tmpY


  # JSON

  toJSON: =>
    {x: @x, y: @y}

  fromJSON: (json = {}, params = {}) =>
    @reset() if params.hard
    @setX json.x, params
    @setY json.y, params

  reset: =>
    @x = null
    @y = null
      

  # old

#  clone: =>
#    new MorpherJS.Point(@x, @y)

#  transform: (matrix) =>
#    tmpX = matrix.get(0,0)*@x + matrix.get(0,1)*@y + matrix.get(0,2)
#    tmpY = matrix.get(1,0)*@x + matrix.get(1,1)*@y + matrix.get(1,2)
#    @x = tmpX
#    @y = tmpY

#  visualize: (el) =>
#    dot = new MorpherJS.DraggableDot()
#    dot.bind 'change', @changeHandler
#    dot.bind 'select', @selectHandler
#    dot.bind 'deselect', @deselectHandler
#    dot.el.appendTo(el)
#    @dots.push dot
#    @updateDots()

#  removeVisualization: =>
#    for dot in @dots
#      dot.remove()
#    @dots = []

#  updateDots: =>
#    for dot in @dots
#      dot.moveTo(@x, @y)

#  changeHandler: (target) =>
#    @x = target.x
#    @y = target.y
#    @updateDots()
#    @trigger 'change', this

#  selectHandler: (target) =>
#    @trigger 'select', this
#  deselectHandler: (target) =>
#    @trigger 'deselect', this
