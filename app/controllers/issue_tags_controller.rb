class IssueTagsController < ApplicationController
  unloadable

  model_object ActsAsTaggableOn::Tag
  before_filter :find_model_object
  before_filter :find_project_by_project_id

  def destroy
    tag = @object

    context = TaggingPlugin::ContextHelper.context_for(@project)

    tag.taggings.find_each(:conditions => ['context=?', context]) do |tagging|
      if tagging.taggable_type = "Issue"
        affected_issue = Issue.find(tagging.taggable_id)
        issue_tags = affected_issue.tag_list_on(context)
        affected_issue.tags_to_update = issue_tags.select { |t| t != tag.name }
        affected_issue.save
      else
        tagging.destroy
      end
    end

    tag.destroy unless tag.taggings.any?

    flash[:notice] = l(:notice_successful_detached)
    redirect_to :controller => 'projects', :action => 'settings', :tab => 'tags', :id => @project
  end
end
