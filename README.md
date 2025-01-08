# Zenity ile Envanter Yönetim Sistemi

Bu proje, Zenity araçlarını kullanarak geliştirilmiş bir envanter yönetim sistemi betiğidir. Sistem, ürün ekleme, listeleme, güncelleme ve silme işlemleri gibi özelliklere sahip bir grafik arayüz sağlar.

## **Özellikler**

- Kullanıcı adı ve şifre ile giriş.
- Ürün ekleme, listeleme, güncelleme ve silme.
- Rapor alma özelliği.
- Kullanıcı yönetimi ve şifre sıfırlama.
- Yönetici ve kullanıcı rolleri arasında yetki farkı.
- Kritik işlemler için onay ekranları.
- Veri doğrulama ve hata kaydı.

## **Klasör Yapısı**

  ```
project_root/
├── scripts/
├── screenshots/
├── data/
└── README.md
```

## **Kurulum**

1. **Gerekli bağımlılıkları yükleyin:**
   ```bash
   sudo apt install zenity
   ```

2. **Proje dosyalarını indirin ve çalıştırın:**
   ```bash
   bash main.sh
   ```

## **Ekran Görüntüleri**

### 1. Giriş Ekranı: Kullanıcı Adı
![Giriş Ekranı - Kullanıcı Adı](./screenshots/ad.png)

### 2. Şifre Ekranı
![Şifre Ekranı](./screenshots/sifre.png)

### 3. Ana Menü
![Ana Menü Ekranı](./screenshots/ana_menu.png)

### 4. Ürün Ekleme   
![Ürün Ekleme Ekranı](./screenshots/urun_ekle.png)

### 5. Ürün Listeleme
![Ürün Listeleme Ekranı](./screenshots/liste.png)

### 6. Ürün Güncelleme
![1.Ürün Güncelleme Ekranı](./screenshots/guncelleme1.png)
![2.Ürün Güncelleme Ekranı](./screenshots/guncelleme2.png)
![3.Ürün Güncelleme Ekranı](./screenshots/guncelleme3.png)
![4.Ürün Güncelleme Ekranı](./screenshots/guncelleme4.png)


### 7. Ürün Silme
![Ürün Silme Ekranı](./screenshots/sil1.png)

### 8. Rapor Alma
![1.Rapor Alma Ekranı](./screenshots/raporAl1.png)
![2.Rapor Alma Ekranı](./screenshots/raporAl2.png)
![3.Rapor Alma Ekranı](./screenshots/raporAl3.png)


### 9. Kullanıcı Yönetimi
![Kullanıcı Yönetimi Ekranı](./screenshots/kullanici.png)

### 10. Şifre Sıfırlama
![1.Şifre Sıfırlama Ekranı](./screenshots/sifre_sifirlama1.png)
![2.Şifre Sıfırlama Ekranı](./screenshots/sifre_sifirlama2.png)
![3.Şifre Sıfırlama Ekranı](./screenshots/sifre_sifirlama3.png)


## Katkıda Bulunmak İsteyenler İçin

1. Projeyi kendi bilgisayarınıza indirin.
2. Geliştirmek istediğiniz özellikleri ekleyin veya mevcut hataları düzeltin.
3. Geliştirmelerinizi ana projeye dahil etmek için bir pull request gönderin.

## Lisans
----------
Bu proje MIT Lisansı ile lisanslanmıştır. Lisans detayları için `LICENSE` dosyasını inceleyebilirsiniz.
