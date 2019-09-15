class ThatNotificationHook  < Redmine::Hook::ViewListener

    def view_layouts_base_html_head(context = {})
        stylesheet_link_tag('that', :plugin => 'that_resent_notification')
    end

    def view_issues_show_details_bottom(context = {})
        if User.current.allowed_to?(:resend_notifications, context[:issue].project) &&
           Setting.notified_events.include?('issue_added')
            context[:hook_caller].send(:render, :partial => 'issues/resend', :locals => context)
        end
    end

    def view_issues_history_journal_bottom(context = {})
        if User.current.allowed_to?(:resend_notifications, context[:journal].project) &&
          (Setting.notified_events.include?('issue_updated') ||
          (Setting.notified_events.include?('issue_note_added') && context[:journal].notes.present?) ||
          (Setting.notified_events.include?('issue_status_updated') && context[:journal].new_status.present?) ||
          (Setting.notified_events.include?('issue_assigned_to_updated') && context[:journal].detail_for_attribute('assigned_to_id').present?) ||
          (Setting.notified_events.include?('issue_priority_updated') && context[:journal].new_value_for('priority_id').present?))
            context[:hook_caller].send(:render, :partial => 'journals/resend', :locals => context)
        end
    end

end
