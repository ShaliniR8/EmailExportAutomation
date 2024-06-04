namespace :email do
  task export_and_delete: :environment do
    # folders = ['Approved', 'Assign Notifs', 'Automated Notifications', 'Creations', 'Message', 'Pending Approval', 'Submissions']
    folders = ['Assign Notifs']
    logger = Logger.new("log/notify.log")

    folders.each do |folder|
      service = EmailService.new
      service.export_emails(folder)
      # service.delete_emails(folder)
      service.logout
    end
    logger.info "#{Date.today} - Exported"
  end
end
