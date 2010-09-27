namespace :redmine do
  namespace :tagging do
    desc "Reconfigure for inline/separate tag editing"
    task :reconfigure => :environment do

      if Setting.plugin_redmine_tagging[:inline] == "1"
        puts "Adding inline tags"

        Issue.find(:all).each {|issue|
          tag_context = issue.project.identifier.gsub('-', '_')
          tags = issue.tag_list_on(tag_context).collect {|tag| tag.gsub(/^#/, '') }.sort.join(', ')

          next if tags.blank? && issue.description.blank?

          tags = "{{tag(#{tags})}}"
  
          issue.description = '' if issue.description.blank?
          issue.description = issue.description.gsub(/[{]{2}tag[(][^)]*[)][}]{2}/i, tags)
          issue.description += "\n\n#{tags}" unless issue.description =~ /[{]{2}tag[(][^)]*[)][}]{2}/i
  
          issue.save!
        }
  
        WikiContent.find(:all).each {|content|
          tag_context = content.page.wiki.project.identifier.gsub('-', '_')
          tags = content.page.tag_list_on(tag_context).collect {|tag| tag.gsub(/^#/, '') }.sort.join(', ')

          next if tags.blank? && content.text.blank?

          tags = "{{tag(#{tags})}}"
  
          content.text = '' if content.text.blank?
          content.text = content.text.gsub(/[{]{2}tag[(][^)]*[)][}]{2}/i, tags)
          content.text += "\n\n#{tags}" unless content.text =~ /[{]{2}tag[(][^)]*[)][}]{2}/i
  
          content.save!
        }
      else
        puts "Removing inline tags"
        Issue.find(:all, :conditions => "lower(description) like '%{{tag(%'").each {|issue|
          next if issue.description.blank?

          issue.description = issue.description.gsub(/[{]{2}tag[(][^)]*[)][}]{2}/i, '')
          issue.save!
        }
  
        WikiContent.find(:all, :conditions => "lower(text) like '%{{tag(%'").each {|content|
          next if content.text.blank?

          content.text = content.text.gsub(/[{]{2}tag[(][^)]*[)][}]{2}/i, '')
          content.save!
        }
      end

    end
  end
end
