include ActionView::Helpers::SanitizeHelper
require 'json'
require 'fileutils'

class EmailService
  def initialize
    @imap = Net::IMAP.new(
      IMAP_SETTINGS[:address],
      IMAP_SETTINGS[:port],
      IMAP_SETTINGS[:enable_ssl]
    )
    @imap.login(
      IMAP_SETTINGS[:user_name],
      IMAP_SETTINGS[:password]
    )
  end

  def fetch_emails(sub_folder)
    @imap.select("INBOX/Action Mailer/#{sub_folder}")
    emails = @imap.search(['ALL'])
    emails.map do |msg_id|
      envelope = @imap.fetch(msg_id, "ENVELOPE")[0].attr["ENVELOPE"]
      body = @imap.fetch(msg_id, "BODY[TEXT]")[0].attr["BODY[TEXT]"]
      to = envelope.to&.map(&:mailbox)&.join(", ")
      cc = envelope.cc&.map(&:mailbox)&.join(", ")
      bcc = envelope.bcc&.map(&:mailbox)&.join(", ")
      {id: msg_id, subject: envelope.subject, to: to, cc: cc, bcc: bcc, body: body}
    end
  end

  def export_emails(sub_folder)
    path = "#{Rails.root}/Exports"
    emails = fetch_emails(sub_folder)
    json = {Date.today => emails}
    full_path = (FileUtils.mkdir_p File.join(path, Date.today.to_s)).first
    export_path = File.join(full_path, "#{sub_folder}.json")
    File.open(export_path, 'wb') do |file|
      file << JSON.pretty_generate(json)
    end
  end

  def delete_emails(sub_folder)
    emails = fetch_emails(sub_folder)
    emails.each do |email|
      @imap.store(email[:id], "+FLAGS", [:Deleted])
    end
    @imap.expunge
    print "Deleted folder #{sub_folder}"
  end

  def logout
    @imap.logout
    @imap.disconnect
  end
end
