class Gui.Views.Popups.BlendFunction extends Backbone.View
  className: 'blend_function'

  template: JST["templates/popups/blend_function"]

  events:
    'change textarea': 'changeHandler'

  changeHandler: =>
    f = @$('textarea').val()
    if f.length
      @model.save blend_function: f
    else
      @model.save blend_function: null
    @refresh()

  refresh: =>
    @$('textarea').val @model.get('blend_function') || MorpherJS.Morpher.defaultBlendFunction.toString()

  render: =>
    @$el.html @template()
    @refresh()
    this
