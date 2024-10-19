#!/bin/bash

if ! command -v /root/.acme.sh/acme.sh &> /dev/null
then
  echo "acme.sh yüklü değil, yüklüyor..."
  curl https://get.acme.sh | sh
  source ~/.bashrc
else
  echo "acme.sh zaten yüklü."
fi

if ! crontab -l | grep -q "/root/.acme.sh/acme.sh --cron"; then
  echo "Cron job yok, ekleniyor..."
  (crontab -l 2>/dev/null; echo "0 3 * * * /root/.acme.sh/acme.sh --cron --home /root/.acme.sh > /dev/null") | crontab -
else
  echo "Cron job zaten var."
fi

hostname=$(hostname)

echo "Hostname: $hostname için SSL kontrol ediliyor..."

if echo | openssl s_client -connect $hostname:443 2>/dev/null | openssl x509 -noout -dates &>/dev/null; then
  echo "Hostname ($hostname) için SSL sertifikası zaten mevcut."
else
  echo "Hostname ($hostname) için SSL bulunamadı, yükleniyor..."

  /root/.acme.sh/acme.sh --issue -d $hostname --webroot /var/www/html
  
  echo "Hostname ($hostname) için WHMAPI1 kullanarak SSL yüklenecek..."

  CERT_PATH="/root/.acme.sh/$hostname/$hostname.cer"
  KEY_PATH="/root/.acme.sh/$hostname/$hostname.key"
  CABUNDLE_PATH="/root/.acme.sh/$hostname/ca.cer"

  whmapi1 install_service_ssl_certificate service=ftp crt="$(cat $CERT_PATH)" key="$(cat $KEY_PATH)" cabundle="$(cat $CABUNDLE_PATH)"
  whmapi1 install_service_ssl_certificate service=exim crt="$(cat $CERT_PATH)" key="$(cat $KEY_PATH)" cabundle="$(cat $CABUNDLE_PATH)"
  whmapi1 install_service_ssl_certificate service=dovecot crt="$(cat $CERT_PATH)" key="$(cat $KEY_PATH)" cabundle="$(cat $CABUNDLE_PATH)"
  whmapi1 install_service_ssl_certificate service=cpanel crt="$(cat $CERT_PATH)" key="$(cat $KEY_PATH)" cabundle="$(cat $CABUNDLE_PATH)"


  
  echo "Hostname ($hostname) için SSL sertifikası başarıyla yüklendi."
fi

for domain in $(ls /var/cpanel/users)
do
  user=$(grep USER= /var/cpanel/users/$domain | cut -d'=' -f2)
  export DEPLOY_CPANEL_USER="$user"
  webroot="/home/$user/public_html"
  
  echo "$domain için SSL sertifikası alınıyor..."
  
  /root/.acme.sh/acme.sh --issue -d $domain --webroot $webroot
  
  echo "$domain için SSL sertifikası CPanel'e yükleniyor..."
  
  /root/.acme.sh/acme.sh --deploy --deploy-hook cpanel_uapi -d $domain
done
