# README

### Ruby version:
ruby 2.7.2p137 (2020-10-01 revision 5445e04352) [x86_64-linux]

### Add a email_settings.rb file with the required IMAP settings.
 This project is setup for IONOS mail server. Please refer to [IONOS Email: Server Data for IMAP, POP3, and SMTP](https://www.ionos.com/help/email/general-topics/settings-for-your-email-programs-imap-pop3/) for more information.

> `cd config/initializers`
> 
> `touch email_settings.rb`

```
require 'net/imap'
require 'mail'

IMAP_SETTINGS = {
  address: xxx,
  port: xxx,
  user_name: xxx,
  password: xxx,
  enable_ssl: true
}.freeze

```

### Set up a cron task to automate this job
 The email_tasks.rake can run on a required interval to automate the process. I like to set it up for daily execution.

> `crontab -e`
```
0 10 * * * /bin/bash -l -c "cd /personal-rails/EmailAutomation/ && /home/prdg/.rvm/gems/ruby-2.7.2/bin/rake email:export_and_delete"
```
