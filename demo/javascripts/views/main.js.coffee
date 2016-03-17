class Gui.Views.Main extends Backbone.View
  projects: null
  projectViews: null
  current: 0

  template: JST["templates/main"]
  className: 'gui-main'

  menu: null

  events:
    'click > .menu > [data-action]'   : 'clickHandler'
    'change .menu input[name=name]' : 'changeHandler'

  initialize: =>
    @projectViews = []
    
    @projects = new Gui.Collections.Projects()
    @projects.bind 'add', @addProjectView
    @projects.bind 'reset', @addAllProjectViews
    @projects.bind 'remove', @removeProjectView

    @render()

    @projects.fetch()
    @showProject @current

  help: =>
    Gui.Views.Popup.show('templates/popups/help')
    

  addProject: =>
    project = @projects.create name: 'New Project'
    @showProject @projects.length-1

  deleteProject: =>
    project = @projects.at(@current)
    if confirm("Are you sure you want to delete '#{project.get('name')}'?")
      project.destroy()
    
  previousProject: =>
    @showProject @current-1

  nextProject: =>
    @showProject @current+1

  showProject: (index) =>
    if @projects.length
      project.hide() for project in @projectViews
      @current = Math.max 0, Math.min @projects.length-1, index
      @projectViews[@current].show()
      @menu.find('input[name=name]').attr(disabled: false).val @projects.at(@current).get('name')
      @menu.find('button[data-action=previousProject]').attr(disabled: @current == 0)
      @menu.find('button[data-action=nextProject]').attr(disabled: @current == @projects.length-1)
      @menu.find('button[data-action=deleteProject]').attr(disabled: false)
      @menu.css backgroundColor: @projects.at(@current).get('color')
    else
      @menu.find('input[name=name]').attr(disabled: true).val('')
      @menu.find('button[data-action=previousProject]').attr(disabled: true)
      @menu.find('button[data-action=nextProject]').attr(disabled: true)
      @menu.find('button[data-action=deleteProject]').attr(disabled: true)
      @menu.css backgroundColor: ''
    
  clickHandler: (e) =>
    @[$(e.currentTarget).data('action')]()


  changeHandler: (e) =>
    input = $(e.currentTarget)
    params = {}
    params[input.attr('name')] = input.val()
    @projects.at(@current).save params


  addProjectView: (project) =>
    projectView = new Gui.Views.Project(model: project)
    @projectViews.push projectView
    projectView.render()
    @menu.find('.project-menus').append projectView.menuEl
    @$el.append projectView.el

  addAllProjectViews: =>
    @projects.each(@addProjectView)

  removeProjectView: (project, collection, params) =>
    @projectViews[params.index].remove()
    delete @projectViews.splice params.index, 1
    @showProject @current-1
      

  render: =>
    @$el.html(@template())
    @menu = @$el.children('.menu')
    this
