require 'redmine'

require_dependency 'that_notification_hook'

Rails.logger.info 'Starting That Resent Notification plugin for Redmine'

Redmine::Plugin.register :that_resent_notification do
    name 'That Resent Notification'
    author 'Andriy Lesyuk for That Company'
    author_url 'http://www.andriylesyuk.com/'
    description 'Allows to resend issue notifications.'
    url 'https://github.com/thatcompany/that_resent_notification'
    version '0.0.1'

    permission :resend_notifications, { :notifications => :resend }, :require => :member
end
