require 'json'

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
      to = envelope.to&.map(&:mailbox)&.join(", ")
      cc = envelope.cc&.map(&:mailbox)&.join(", ")
      bcc = envelope.bcc&.map(&:mailbox)&.join(", ")
      { id: msg_id, subject: envelope.subject, to: to, cc: cc, bcc: bcc}
    end
  end

  def export_emails(sub_folder)
    path = "#{Rails.root}/Exports"
    emails = fetch_emails(sub_folder)
    json = {Date.today => emails}
    export_path = File.join(path, "#{sub_folder}_#{Date.today.to_s}.pdf")
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
