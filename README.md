
Betiğin İşlevi:
acme.sh'yi kontrol eder ve gerekirse yükler.
Cron job ile sertifikaların otomatik yenilenmesini sağlar.
Sunucunun hostname'i için SSL sertifikası olup olmadığını kontrol eder, yoksa yenisini alır ve ilgili hizmetlere yükler.
Sunucudaki tüm CPanel kullanıcıları için domain bazlı SSL sertifikaları alır ve yükler.
Kullanım Alanları:
Bu betik, CPanel/WHM kullanan sunucularda SSL sertifikalarının otomatik olarak alınmasını, yenilenmesini ve yüklenmesini sağlamak için tasarlanmıştır. Özellikle, birden fazla kullanıcısı olan sunucularda SSL yönetimini kolaylaştırır.

Bu Bash betiği, sunucunuzun acme.sh aracını kullanarak tüm alan adlarına ve hostname üzerine otomatik SSL sertifikası almasını, yenilemesini ve WHM (Web Host Manager) ile CPanel'de hizmetlere SSL yüklemesini sağlar.

Kurulum
bash <(curl https://raw.githubusercontent.com/mertkaracali/cpanel-auto-ssl/refs/heads/main/install.sh)
