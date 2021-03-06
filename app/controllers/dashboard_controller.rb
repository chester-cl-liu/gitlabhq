class DashboardController < Dashboard::ApplicationController
  include IssuesAction
  include MergeRequestsAction

  before_action :event_filter, only: :activity
  before_action :projects, only: [:issues, :merge_requests]
  before_action :set_show_full_reference, only: [:issues, :merge_requests]

  respond_to :html

  def activity
    respond_to do |format|
      format.html

      format.json do
        load_events
        pager_json("events/_events", @events.count)
      end
    end
  end

  protected

  def load_events
    projects =
      if params[:filter] == "starred"
        current_user.viewable_starred_projects
      else
        current_user.authorized_projects
      end

    @events = Event.in_projects(projects)
    @events = @event_filter.apply_filter(@events).with_associations
    @events = @events.limit(20).offset(params[:offset] || 0)
  end

  def set_show_full_reference
    @show_full_reference = true
  end
end
