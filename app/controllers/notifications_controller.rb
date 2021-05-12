class NotificationsController < ApplicationController

    before_action :find_notifiable, :check_visibility
    before_action :authorize

    def resend
        if request.get?
            redirect_to_referer_or do
                render :html => l(:label_no_data), :status => 200, :layout => true
            end
            return
        end

        case @notifiable
        when Issue
            if Setting.notified_events.include?('issue_added')
                Mailer.deliver_issue_add(@notifiable)
            else
                @error_message = l(:error_notification_disabled)
            end
        when Journal
            if Setting.notified_events.include?('issue_updated') ||
              (Setting.notified_events.include?('issue_note_added') && @notifiable.notes.present?) ||
              (Setting.notified_events.include?('issue_status_updated') && @notifiable.new_status.present?) ||
              (Setting.notified_events.include?('issue_assigned_to_updated') && @notifiable.detail_for_attribute('assigned_to_id').present?) ||
              (Setting.notified_events.include?('issue_priority_updated') && @notifiable.new_value_for('priority_id').present?)
                Mailer.deliver_issue_edit(@notifiable)
            else
                @error_message = l(:error_notification_disabled)
            end
        else
            @error_message = l(:error_notification_unsupported)
        end

        if referer = request.headers['Referer']
            if @error_message
                flash[:error] = @error_message
            else
                flash[:notice] = l(:notice_notification_sent)
            end
            referer.sub!(%r{/rit_history}, '') if Redmine::Plugin.installed?(:redmine_issue_tabs)
            redirect_to referer
        else
            render :html => @error_message || l(:notice_notification_sent), :status => @error_message ? 403 : 200, :layout => true
        end
    end

private

    def find_notifiable
        klass = Object.const_get(params[:object_type].camelcase)
        @notifiable = klass.find(params[:object_id])
        @project = @notifiable.project
    rescue NameError, ActiveRecord::RecordNotFound
        render_404
    end

    def check_visibility
        if @notifiable.respond_to?(:visible?)
            raise Unauthorized unless @notifiable.visible?
        elsif @notifiable.is_a?(Journal)
            raise Unauthorized if (@notifiable.private_notes? && @notifiable.user != User.current && !User.current.allowed_to?(:view_private_notes, @project)) ||
                                  (!@notifiable.notes? && @notifiable.visible_details.empty?) || !@notifiable.journalized.visible?
        end
    end

end
