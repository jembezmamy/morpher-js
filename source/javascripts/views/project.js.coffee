class Gui.Views.Project extends Backbone.View
  className: 'project'

  menuTemplate: JST["templates/project_menu"]
  menuEl: null

  imageViews: null
  previewView: null

  selectedPoints: null

  initialize: =>
    @$menuEl = $('<div />').addClass('project-menu')
    @menuEl = @$menuEl[0]
    @$menuEl.on 'click', '[data-action]', @clickHandler

    @model.morpher.on "resize", @updateImagesSize
    @model.morpher.on "load", @loadHandler

    @previewView = new Gui.Views.Tile()

    @selectedPoints = []
    
    @imageViews = []
    @model.images.bind 'add', @addImageView
    @model.images.bind 'reset', @addAllImageViews
    @model.images.bind 'remove', @removeImageView


  # public methods

  save: =>
    @model.save()

  show: =>
    @$menuEl.addClass('visible')
    @$el.addClass('visible')

  hide: =>
    @$menuEl.removeClass('visible')
    @$el.removeClass('visible')

  remove: =>
    @$menuEl.remove()
    super


  # image views

  addImage: =>
    @model.images.create()

  addImageView: (image) =>
    imageView = new Gui.Views.Image(model: image)
    @imageViews.push imageView
    imageView.on 'drag:stop', @save
    imageView.on 'highlight', @hightlightHandler
    imageView.on 'select', @selectHandler
    @$el.append imageView.render().el
    @arrangeImages()
    if image.isNew()
      imageView.openFile()

  addAllImageViews: =>
    for view in @imageViews
      view.remove()
    @imageViews = []
    @model.images.each(@addImageView)

  removeImageView: (image, collection, params)=>
    @imageViews[params.index].remove()
    delete @imageViews.splice params.index, 1
    @arrangeImages()

  updateImagesSize: (morpher, canvas) =>
    for image in @imageViews
      image.setSize canvas.width, canvas.height

  arrangeImages: =>
    views = @imageViews.slice 0
    views.splice views.length/2, 0, @previewView
    count = views.length
    for image, i in views
      image.setPosition i/count, 0, 1/count, 1

  hightlightHandler: (index, state) =>
    for image in @imageViews
      image.highlightPoint index, state

  selectHandler: (index) =>
    i = @selectedPoints.indexOf(index)
    if i != -1
      @selectedPoints.splice i, 1
    else
      @selectedPoints.push index
    if @selectedPoints.length < 3
      for image in @imageViews
        image.selectPoint index, i == -1
    else
      @model.addTriangle @selectedPoints[0], @selectedPoints[1], @selectedPoints[2]
      for image in @imageViews
        for p in @selectedPoints
          image.selectPoint p, false
      @selectedPoints = []


  loadHandler: (morpher, canvas)=>
    image.addAllPointViews() for image in @imageViews
    @updateImagesSize(morpher, canvas)
  

  clickHandler: (e) =>
    @[$(e.currentTarget).data('action')]()

  render: =>
    @$menuEl.html @menuTemplate()
    @previewView.render().$el.appendTo @el
    @previewView.$pane.append @model.morpher.canvas
    @addAllImageViews()
    this
