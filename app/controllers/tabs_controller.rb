class TabsController < ApplicationController
  def index
    if params[:search]
      search_params.includes(:trees)
    else
      tabs = Tab.all.includes(:trees)
      render locals: { tabs: tabs }
    end
  end

  def show
    tab = find_by_tab_params
    if tab
      render locals: { tab: tab }
    else
      redirect_to tabs
    end
  end

  def new
    render locals: { tab: Tab.new }
  end

  def create
    tab = Tab.new(tab_params)
    tab.user = current_user
    if tab.save
      redirect_to tab.tab_root
    else
      flash[:alert] = "The tab could not be created"
      render template: 'tabs/new.html.erb', locals: { tab: tab}
    end
  end

  def edit
    render locals: { tab: find_by_tab_params }
  end

  def update
    tab = find_by_tab_params
    if tab.update(tab_params)
      redirect_to tab.tab_root
    else
      render template: 'tabs/edit.html.erb', locals: { tab: tab }
    end
  end

  def destroy
    tab = find_by_tab_params

    if tab.parent
      tabchild = where_tab_params
      tabchild.each do |tc|
        tc.parent_tab_id = tab.parent.id
        tc.save
      end
    end

    if tab.destroy
      flash[:alert] = "Take that, Greenpeace!"
      redirect_to root_path
    else
      render message: "Tab not found."
    end
  end

  private

  def tab_params
    params.require(:tab).permit(:tree_id, :user_id, :name, :url, :parent_tab_id)
  end
end
