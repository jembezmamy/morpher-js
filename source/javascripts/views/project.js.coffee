class Gui.Views.Project extends Backbone.View
  className: 'project'

  menuTemplate: JST["templates/project_menu"]
  menuEl: null

  imageViews: null

  initialize: =>
    @$menuEl = $('<div />').addClass('project-menu')
    @menuEl = @$menuEl[0]
    @$menuEl.on 'click', '[data-action]', @clickHandler

    @imageViews = []
    @model.images.bind 'add', @addImageView
    @model.images.bind 'reset', @addAllImageViews
    @model.images.bind 'remove', @removeImageView

  show: =>
    @$menuEl.addClass('visible')
    @$el.addClass('visible')

  hide: =>
    @$menuEl.removeClass('visible')
    @$el.removeClass('visible')

  remove: =>
    @$menuEl.remove()
    super


  addImage: =>
    @model.images.create()

  addImageView: (image) =>
    imageView = new Gui.Views.Image(model: image)
    @imageViews.push imageView
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

  arrangeImages: =>
    count = @imageViews.length
    for image, i in @imageViews
      image.setPosition i/count, 0, 1/count, 1
  

  clickHandler: (e) =>
    @[$(e.currentTarget).data('action')]()

  render: =>
    @$menuEl.html @menuTemplate()
    @addAllImageViews()
    this
