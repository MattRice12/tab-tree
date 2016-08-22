class ApplicationController < ActionController::Base
  before_action :require_login

  include Clearance::Controller
  protect_from_forgery with: :exception

  TAB_CREATED     = "Tab Created."
  TREE_CREATED    = "Tree Created."
  FOREST_CREATED  = "Tree Created and Added to Project."
  PROJECT_CREATED = "Project Created."

  TAB_UPDATED     = "Tab Name Updated."
  TREE_UPDATED    = "Tree Name Updated."
  PROJECT_UPDATED = "Project Name Updated."

  TAB_DESTROYED = "Tab Destroyed."
  TREE_DESTROYED    = "Tree Destroyed. Take that, Greenpeace!"
  FOREST_DESTROYED  = "That piece of the forest was as ancient as time... and you destroyed it..."
  PROJECT_DESTROYED = "The project disbanded. Thanks, Obama."
  NOT_DELETE = "Error: You cannot delete a "

  TAB_NOT_EXIST  = "That tab does not exist."
  TREE_NOT_EXIST = "That tree does not exist."
  PROJ_NOT_EXIST = "That project does not exist."

  TAB_UNAUTH  = "You are not authorized to access that tab."
  TREE_UNAUTH = "You are not authorized to access that tree."
  PROJ_UNAUTH = "You are not authorized to access that project."

  def search_params
    tabs = Tab.search(params[:search]).where(user_id: current_user.id)
    users = User.search(params[:search]).order("LOWER(name)")
    render template: 'trees/search.html.erb', locals: { tabs: tabs, users: users }
  end

  def tab_adoption(tab)
    if tab.parent
      tabchild = Tab.where(parent_tab_id: tab.id)
      tabchild.each do |tc|
        tc.parent_tab_id = tab.parent.id
        tc.save
      end
    end
  end

  def tree_adoption(tab)
    if tab.tree
      tabchild = Tab.where(parent_tab_id: tab.id)
      tabchild.each do |tc|
        tc.tree_id = tab.tree.id
        tc.parent_tab_id = nil
        tc.save
      end
    end
  end

  def redirect(loc, alert)
    flash[:alert] = alert
    redirect_to loc
  end

################## FINDERS #################
  def find_tab_params(obj)
    Tab.find_by(id: params[obj])
  end

  def where_tab_params
    Tab.where(parent_tab_id: params[:id])
  end

  def find_tree_params(obj)
    Tree.find_by(id: params[obj])
  end

  def find_forest_params
    Forest.find(params[:id])
  end

  def find_proj_param_obj(obj)
    Project.find_by(id: params[obj])
  end

  def find_proj_by_param_obj_proj(obj)
    Project.find_by(id: params[obj][:project_id])
  end
################## GRABBERS #################

################## PERMISSIONS #################
  def tab_permission?(obj)
    current_user.trees.any? { |tr| tr == obj.tab_root }
  end

  def tree_permission?(obj)
    tree = obj
    [
      current_user.id == tree.user_id,
      current_user.projects.any? { |proj| proj.trees.any? { |tr| tr.id } } == params[:id]
    ].any?
  end

  def project_permission?(obj)
    project = obj
    project.members.any? { |m| m.user_id == current_user.id }
  end
################## PERMISSIONS #################

################## VALIDATIONS #################
  def tab_validations(obj)
    return redirect(trees_path, TAB_NOT_EXIST) if !obj
    return redirect(trees_path, TAB_UNAUTH) if !tab_permission?(obj)
  end

  def tree_validations(obj)
    return redirect(trees_path, TREE_NOT_EXIST) if !obj
    return redirect(trees_path, TREE_UNAUTH) if !tree_permission?(obj)
  end

  def proj_validations(obj)
    return redirect(projects_path, PROJ_NOT_EXIST) if !obj
    return redirect(projects_path, PROJ_UNAUTH) if !project_permission?(obj)
  end
################## VALIDATIONS #################

end
