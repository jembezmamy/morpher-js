class Gui.Views.Popups.EditFunction extends Backbone.View
  className: 'edit_function'

  template: JST["templates/popups/edit_function"]
  paramName: null

  events:
    'change textarea': 'changeHandler'

  initialize: (params = {}) =>
    @paramName = params.name

  changeHandler: =>
    f = @$('textarea').val()
    params = {}
    if f.length
      params[@paramName] = f
    else
      params[@paramName] = null
    @model.save params
    @refresh()

  refresh: =>
    defaultValue = if @paramName == 'blend_function'
      MorpherJS.Morpher.defaultBlendFunction.toString()
    else
      @sampleFinalTouchFunction.toString()
    @$('textarea').val @model.get(@paramName) || defaultValue

  sampleFinalTouchFunction: (canvas) ->

  render: =>
    @$el.empty().append $('<textarea />').addClass('code')
    @refresh()
    this
