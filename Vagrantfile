Vagrant.configure("2") do |config|
  config.vm.box = "almalinux/8"
    config.vm.provision "shell", inline: <<-SHELL
      sudo dnf install -y mutt cyrus-sasl-plain
      sudo mkdir /home/vagrant/.mutt/
      passformail=notarealpassword
      echo -en "set realname = LinuxServer\nset from = z645@yandex.ru\nset use_from = yes\nset imap_user = z645@yandex.ru\nset imap_pass = $passformail\nset spoolfile = imaps://z645@imap.yandex.ru\nset folder = imaps://imap.yandex.ru:993\nset record = =Отправленные\nset trash = =Удаленные\nset ssl_starttls = yes\nset ssl_force_tls = yes\nunset imap_passive\nset imap_check_subscribed\nset mail_check = 60\nset smtp_url = smtps://z645@smtp.yandex.ru:465\nset smtp_pass = $passformail\n\n" | sudo tee /home/vagrant/.mutt/muttrc
      sudo chown -R vagrant:vagrant /home/vagrant/.mutt/
      echo -e '0  */1  *  *  * vagrant    test -f /var/tmp/script.lock || /vagrant/script.sh' | sudo tee -a /etc/crontab
    SHELL
end
