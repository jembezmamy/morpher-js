class MorpherJS.Image extends MorpherJS.EventDispatcher
  el: null

  points: null

  constructor: (json = {}) ->
    @el = new window.Image()
    @el.onload = @loadHandler
    @points = []
    @fromJSON json
    

  # setters & getters

  setSrc: (src) =>
    @el.src = src


  # points

  addPoint: (point, params = {}) =>
    unless point instanceof MorpherJS.Point
      point = new MorpherJS.Point point.x, point.y
    point.on "change", @changeHandler
    @points.push point
    @trigger 'point:add', point unless params.silent
    point

  removePoint: (point) =>
    i = @points.indexOf point
    if i != -1
      delete @points.splice i, 1
      @trigger 'point:remove'

  makeCompatibleWith: (image) =>
    if @points.length != image.points.length
      console.warn "Incompatible mesh - number of the points should be equal" if console?
      if @points.length > image.points.length
        @points.splice image.points.length, @points.length-image.points.length
      else
        for point in image.points[(@points.length)..(image.points.length)]
          @addPoint point.x, point.y

  changeHandler: =>
    @trigger 'change'


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
