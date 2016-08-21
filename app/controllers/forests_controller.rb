class ForestsController < ApplicationController
  def new
    if project = Project.find_by(id: params[:project_id])
      if project.members.any? { |m| m.user_id == current_user.id }
        render locals: { forest: Forest.new }
      else
        flash[:alert] = "You are not authorized to access this project."
        redirect_to projects_path
      end
    else
      flash[:alert] = "This project does not exist."
      redirect_to projects_path
    end
  end

  def create
    if project_permission?(:forest)
      forest = Forest.find_or_create_by(forest_params)
      redirect_to project_path(forest.project)
    else
      flash[:alert] = "You are not authorized to access this project."
      redirect_to projects_path
    end
  end

  def destroy
    forest  = Forest.find(params[:id])
    project = forest.project
    if forest.destroy
      flash[:alert] = "This tree was as ancient as time... and you destroyed it..."
      redirect_to project
    else
      flash[:alert] = "The fairies protect this tree. You failed to destroy it."
    end
  end

  private

  def forest_params
    params.require(:forest).permit(:project_id, :tree_id)
  end

end
