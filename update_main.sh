#!/bin/bash

# CSV dosyalarını kontrol et ve başlat
function initialize_files {
  [[ ! -f "depo.csv" ]] && echo "ID,Adı,Stok,Fiyat,Kategori" > depo.csv
  [[ ! -f "kullanici.csv" ]] && echo "ID,Adı,Soyadı,Rol,Parola,Deneme Sayısı,Hesap Durumu" > kullanici.csv
  [[ ! -f "log.csv" ]] && echo "Tarih,Zaman,Kullanıcı,Hata" > log.csv
}

# Giriş ekranı
function login_screen {
  local username=$(zenity --entry --title="Giriş" --text="Kullanıcı adınızı girin:")
  local password=$(zenity --password --title="Giriş")
  validate_user "$username" "$password"
}

# Kullanıcı doğrulama
function validate_user {
  local username=$1
  local password=$2
  local hashed_password=$(echo -n "$password" | md5sum | awk '{print $1}')
  
  # Kullanıcıyı doğrula
  if grep -q ",$username,.*,$hashed_password" kullanici.csv; then
    # Hesap durumu kontrolü (kilitli olup olmadığını kontrol et)
    local lock_status=$(grep "$username" kullanici.csv | cut -d ',' -f 7)
    if [[ "$lock_status" == "Kilitli" ]]; then
      zenity --error --text="Hesabınız kilitlenmiş. Yönetici ile iletişime geçin."
      exit 1
    fi

    # Başarılı giriş
    sed -i "s/\($username,[^,],[^,],[^,],[^,],\)[0-9]\(,.\)/\10\2/" kullanici.csv
    zenity --info --text="Giriş başarılı. Hoş geldiniz, $username!"
    local role=$(grep "$username" kullanici.csv | cut -d ',' -f 4)
    main_menu "$username" "$role"
  else
    # Hatalı giriş yapılırsa deneme sayısını artır
    local current_attempts=$(grep "$username" kullanici.csv | cut -d ',' -f 6)
    if [[ -z "$current_attempts" ]]; then
      current_attempts=0
    fi
    new_attempts=$((current_attempts + 1))
    sed -i "s/\($username,[^,],[^,],[^,],[^,],\)[0-9]\(,.\)/\1$new_attempts\2/" kullanici.csv

    # 3 başarısız deneme sonrası hesabı sil
    if [[ $new_attempts -ge 3 ]]; then
      sed -i "/$username/d" kullanici.csv
      echo "$(date),Silindi,$username,Hesap 3 başarısız girişten dolayı silindi" >> log.csv
      zenity --error --text="Hesabınız 3 başarısız giriş nedeniyle silinmiştir."
      exit 1
    fi

    # Hata kaydı ve bilgi
    echo "$(date),Hata,$username,Hatalı giriş" >> log.csv
    zenity --error --text="Geçersiz kullanıcı adı veya parola!"
    login_screen
  fi
}

# Ana Menü
function main_menu {
  local username=$1
  local role=$2
  while true; do
    local choice=$(zenity --list --title="Ana Menü" --column="Seçenekler" \
      "1. Ürün Ekle" \
      "2. Ürün Listele" \
      "3. Ürün Güncelle" \
      "4. Ürün Sil" \
      "5. Rapor Al" \
      "6. Kullanıcı Yönetimi" \
      "7. Şifre Sıfırlama" \
      "8. Çıkış")

    case $choice in
      "1. Ürün Ekle") [[ $role == "Yönetici" ]] && add_product || unauthorized_action ;;
      "2. Ürün Listele") list_products ;;
      "3. Ürün Güncelle") [[ $role == "Yönetici" ]] && update_product || unauthorized_action ;;
      "4. Ürün Sil") [[ $role == "Yönetici" ]] && delete_product || unauthorized_action ;;
      "5. Rapor Al") generate_report ;;
      "6. Kullanıcı Yönetimi") [[ $role == "Yönetici" ]] && user_management || unauthorized_action ;;
      "7. Şifre Sıfırlama") [[ $role == "Yönetici" ]] && reset_password || unauthorized_action ;;
      "8. Çıkış") exit_program ;;
      *) zenity --error --text="Geçersiz seçim!" ;;
    esac
  done
}

# Ürün ekleme
function add_product {
  local product_info=$(zenity --forms --title="Ürün Ekle" --text="Ürün bilgilerini girin:" \
    --add-entry="Ürün Adı" --add-entry="Stok Miktarı" --add-entry="Birim Fiyatı" --add-entry="Kategori")
  local name=$(echo "$product_info" | cut -d '|' -f 1)
  local stock=$(echo "$product_info" | cut -d '|' -f 2)
  local price=$(echo "$product_info" | cut -d '|' -f 3)
  local category=$(echo "$product_info" | cut -d '|' -f 4)

  if [[ -z "$name" || -z "$stock" || -z "$price" || -z "$category" || "$stock" -lt 0 || "$price" -lt 0 ]]; then
    zenity --error --text="Geçersiz veri girişi!"
    echo "$(date),Hata,Geçersiz ürün ekleme bilgisi" >> log.csv
  else
    local id=$(( $(tail -n +2 depo.csv | wc -l) + 1 ))
    echo "$id,$name,$stock,$price,$category" >> depo.csv
    zenity --info --text="Ürün başarıyla eklendi."
  fi
}

# Ürün Silme
function delete_product {
  # Yalnızca yönetici bu işlemi yapabilir
  if [[ $role != "Yönetici" ]]; then
    unauthorized_action
    return
  fi

  # Kullanıcıdan silmek istediği ürünün adı alınır
  local product_name=$(zenity --entry --title="Ürün Sil" --text="Silmek istediğiniz ürünün adını girin:")

  # Ürün dosyasını kontrol et
  if grep -q ",$product_name," depo.csv; then
    # Ürünü CSV dosyasından sil
    sed -i "/,$product_name,/d" depo.csv
    
    # Silme işleminde log kaydı
    echo "$(date),Ürün Silme,$username,$product_name" >> log.csv
    zenity --info --text="Ürün başarıyla silindi: $product_name"
  else
    # Ürün bulunamadığında hata mesajı
    zenity --error --text="Ürün bulunamadı: $product_name"
  fi
}

# Ürün Güncelleme
function update_product {
  # Yalnızca yönetici bu işlemi yapabilir
  if [[ $role != "Yönetici" ]]; then
    unauthorized_action
    return
  fi

  # Kullanıcıdan güncellemek istediği ürünün adı alınır
  local product_name=$(zenity --entry --title="Ürün Güncelle" --text="Güncellemek istediğiniz ürünün adını girin:")

  # Ürün numarasını CSV dosyasından bul
  local product_line=$(grep ",$product_name," depo.csv)

  if [[ -n "$product_line" ]]; then
    # Ürün bulunduysa, kullanıcıdan yeni stok miktarı, birim fiyatı ve kategori isteniyor
    local new_stock=$(zenity --entry --title="Stok Miktarı Güncelle" --text="Yeni stok miktarını girin:" --entry-text=$(echo $product_line | cut -d ',' -f 2))
    local new_price=$(zenity --entry --title="Birim Fiyatı Güncelle" --text="Yeni birim fiyatını girin:" --entry-text=$(echo $product_line | cut -d ',' -f 3))
    local new_category=$(zenity --entry --title="Kategori Güncelle" --text="Yeni kategori bilgisini girin:" --entry-text=$(echo $product_line | cut -d ',' -f 4))

    # Mevcut satırdaki ID'yi koruyarak alıyoruz
    local id=$(echo "$product_line" | cut -d ',' -f 1)

    # Güncellenmiş bilgileri hazırlıyoruz, ID'yi koruyarak
    local updated_line="$id,$product_name,$new_stock,$new_price,$new_category"
    
    # Güncellenmiş satırı dosyaya yaz
    sed -i "/,$product_name,/c\\$updated_line" depo.csv

    # Güncelleme işleminde log kaydı
    echo "$(date),Ürün Güncelleme,$username,$product_name" >> log.csv
    zenity --info --text="Ürün başarıyla güncellendi: $product_name"
  else
    # Ürün bulunamadığında hata mesajı
    zenity --error --text="Ürün bulunamadı: $product_name"
  fi
}



# Rapor Al
function generate_report {
  # Yalnızca yönetici bu işlemi yapabilir
  if [[ $role != "Yönetici" ]]; then
    unauthorized_action
    return
  fi

  # Kullanıcıdan rapor tipi seçmesi istenir
  report_type=$(zenity --list --radiolist --title="Rapor Al" --text="Bir rapor türü seçin:" \
    --column="Seç" --column="Rapor Türü" TRUE "Stokta Azalan Ürünler" FALSE "En Yüksek Stok Miktarına Sahip Ürünler")

  case $report_type in
    "Stokta Azalan Ürünler")
      # Eşik değeri istenir
      threshold=$(zenity --entry --title="Stok Eşik Değeri" --text="Stokta azalan ürünleri görmek için eşik değeri girin:")

      # CSV dosyasındaki ürünleri kontrol et ve eşik değerinin altındaki ürünleri listele
      result=$(awk -F',' -v threshold="$threshold" '$3 < threshold {print $2 ", Stok: " $3 ", Fiyat: " $4 ", Kategori: " $5}' depo.csv)
      
      if [[ -n "$result" ]]; then
        # Raporu kullanıcıya göster
        zenity --info --title="Stokta Azalan Ürünler" --text="$result"
      else
        zenity --info --title="Stokta Azalan Ürünler" --text="Eşik değerinin altına düşen ürün bulunamadı."
      fi
      ;;
    "En Yüksek Stok Miktarına Sahip Ürünler")
      # Eşik değeri istenir
      threshold=$(zenity --entry --title="Stok Eşik Değeri" --text="En yüksek stok miktarına sahip ürünleri görmek için eşik değeri girin:")

      # CSV dosyasındaki ürünleri kontrol et ve eşik değerinin üstündeki ürünleri listele
      result=$(awk -F',' -v threshold="$threshold" '$3 >= threshold {print $2 ", Stok: " $3 ", Fiyat: " $4 ", Kategori: " $5}' depo.csv)
      
      if [[ -n "$result" ]]; then
        # Raporu kullanıcıya göster
        zenity --info --title="En Yüksek Stok Miktarına Sahip Ürünler" --text="$result"
      else
        zenity --info --title="En Yüksek Stok Miktarına Sahip Ürünler" --text="Eşik değerinin üstünde ürün bulunamadı."
      fi
      ;;
  esac
}

# Ürünleri listeleme
function list_products {
  zenity --text-info --title="Ürün Listesi" --filename=<(tail -n +2 depo.csv | column -s ',' -t)
}

# Kullanıcı yönetimi
function user_management {
  local user_choice=$(zenity --list --title="Kullanıcı Yönetimi" --column="Seçenekler" \
    "1. Kullanıcı Kilitle" \
    "2. Kullanıcı Kilidini Aç" \
    "3. Kullanıcı Sil" \
    "4. Geri")

  case $user_choice in
    "1. Kullanıcı Kilitle") lock_user ;;
    "2. Kullanıcı Kilidini Aç") unlock_user ;;
    "3. Kullanıcı Sil") delete_user ;;
    "4. Geri") main_menu ;;
    *) zenity --error --text="Geçersiz seçim!" ;;
  esac
}

function reset_password {
  local username=$(zenity --entry --title="Şifre Sıfırlama" --text="Şifre sıfırlamak istediğiniz kullanıcı adını girin:")

  if grep -q ",$username," kullanici.csv; then
    local new_password=$(zenity --entry --title="Yeni Şifre" --text="Yeni şifreyi girin:")
    local confirm_password=$(zenity --entry --title="Yeni Şifre (Doğrulama)" --text="Yeni şifreyi tekrar girin:")

    if [[ "$new_password" == "$confirm_password" ]]; then
      local hashed_password=$(echo -n "$new_password" | md5sum | awk '{print $1}')
      
      # Şifre sıfırlama işlemi
      sed -i "/,$username,/ s/[^,]*$/,$hashed_password/" kullanici.csv
      echo "$(date +'%Y-%m-%d %H:%M:%S'),Şifre sıfırlama,$username" >> log.csv
      zenity --info --text="Şifreniz başarıyla sıfırlandı."
    else
      zenity --error --text="Girilen şifreler eşleşmiyor!"
    fi
  else
    zenity --error --text="Kullanıcı bulunamadı!"
    echo "$(date +'%Y-%m-%d %H:%M:%S'),Şifre sıfırlama başarısız,$username" >> log.csv
  fi
}




# Yetkisiz işlem
function unauthorized_action {
  zenity --error --text="Yetkisiz işlem!"
}

# Çıkış işlemi
function exit_program {
  zenity --info --text="Çıkılıyor..."
  exit 0
}

initialize_files
login_screen