# 🎟️ Etkinlik Rezervasyon Sistemi

Bu proje, kullanıcıların güncel etkinlikleri görüntüleyebileceği, tarihe göre filtreleme yapabileceği ve gerçek zamanlı kontenjan kontrolü ile rezervasyon oluşturabileceği uçtan uca (Full-Stack) bir mobil uygulamadır. Sistem, yüksek eşzamanlı istekler altında veri tutarlılığını korumak üzere tasarlanmıştır.

## ✨ Özellikler

- ✅ JWT ile Kimlik Doğrulama
- ✅ Kullanıcı Kayıt ve Giriş
- ✅ Etkinlik Listeleme
- ✅ Tarihe Göre Filtreleme
- ✅ Sayfalama (Pagination)
- ✅ Gerçek Zamanlı Kontenjan Kontrolü
- ✅ Rezervasyon Oluşturma
- ✅ Rezervasyon İptali
- ✅ Kullanıcı Rezervasyonları
- ✅ Pull-to-Refresh (Bonus)
- ✅ Docker ile PostgreSQL Kurulumu (Bonus)
- ✅ Jest Birim Testleri (Bonus)

## 🎥 Demo ve Dokümantasyon
* **Sistem Mimarisi:** Proje geliştirilmesine başlanmadan önce planlanan altyapı ve sistem akışı detayları için [`docs/system-architecture.pdf`](docs/system-architecture.pdf) dosyasını inceleyebilirsiniz. *(Not: GitHub önizleme ekranında dosya boyutundan dolayı render hatası alabilirsiniz. Bu durumda dosyayı görüntülemek için sağ üst köşedeki "Download" (İndir) butonunu kullanabilirsiniz.)*
* **Uygulama Videosu:** Uygulamanın uçtan uca akışını tarayıcı üzerinden hızlıca izlemek için **[Buraya Tıklayarak İzleyebilirsiniz 🔗](https://drive.google.com/file/d/1lcl3Ac6wGAVTsVt3d7r78Apu2ebD-iwg/view?usp=sharing)**. Alternatif olarak proje içerisindeki [`docs/recording_app.mp4`](docs/recording_app.mp4) dizininden videoyu indirebilirsiniz.
* **API Dokümanı:** Proje içerisindeki Postman koleksiyonu ([`docs/event_reservation_api.json`](docs/event_reservation_api.json) dosyası) ile tüm endpoint'leri test edebilirsiniz.

---

## 🧠 Teknik Kararlar ve Gerekçeleri

### 1. Eşzamanlılık ve Race Condition Koruması
*Aynı anda gelen iki istek toplam kontenjanı aşamamalıdır.* Bu durumu engellemek amacıyla **veritabanı düzeyinde** önlem alınmıştır. Rezervasyon oluşturma işlemi, tek bir **Prisma $transaction** bloğu altında gerçekleştirilir. Kontenjan güncelleme sorgusunda (`available_quota: { decrement: guest_count }`) veritabanı seviyesinde `gte` (büyük veya eşit) şartı kullanılarak "doğrudan güncelleme" tekniği uygulanmıştır. Böylece iki farklı isteğin aynı boş koltuğu rezerve etmesinin (Overbooking) tamamen önüne geçilmiştir.

### 2. State Yönetimi (Mobil)
Flutter tarafında state yönetimi için **Riverpod** tercih edilmiştir.
* **Gerekçe:** Riverpod'un asenkron işlemleri (`AsyncValue` ile Loading/Data/Error durumlarını) yönetmedeki gücü, `autoDispose` özelliği ile bellek sızıntılarını önlemesi ve pagination (sonsuz kaydırma) yapısını UI tarafında çok daha temiz bir mimariyle kurmaya olanak tanıması nedeniyle bu araç seçilmiştir.

### 3. Yapay Zeka Kullanım Beyanı
Geliştirme süreci boyunca Google Gemini modelinden destek alınmıştır.
* **Kullanım Alanları:** Prisma $transaction için Jest ile mock birim testlerinin (unit test) yazılması, UI tarafında tasarımın optimize edilmesi, README dokümantasyonu ve bazı Typescript tip hatalarının ayıklanması aşamalarında yapay zeka asistanı olarak faydalanılmıştır.

---

## 📌 Varsayımlar ve Bilinen Eksikler
* **Varsayım (Pagination):** Listeleme isteklerinde varsayılan sayfa başı veri limiti (limit), sonsuz kaydırmanın UI tarafında net ve hızlı test edilebilmesi adına bilerek düşük rakamlar (4) olarak varsayılmış ve uygulanmıştır.
* **Varsayım (Admin İşlemleri):** Proje bir ilk sürüm (MVP) olarak değerlendirildiği için, mobil arayüzde bir "Admin" paneli tasarlanmamıştır. Etkinliklerin sisteme girmesi backend tarafındaki seed mekanizmasına bırakılmıştır.

---

## 🛠️ Kullanılan Teknolojiler
- **Backend:** Node.js, Express.js, TypeScript
- **Veritabanı:** PostgreSQL, Prisma ORM
- **Kimlik Doğrulama:** JWT, bcrypt
- **Container:** Docker (PostgreSQL)
- **Test:** Jest, ts-jest
- **Mobil:** Flutter, Riverpod, GoRouter, Dio

---

## ⚙️ Kurulum ve Çalıştırma Adımları

Projeyi ayağa kaldırmak için **Docker (Önerilen)** veya **Manuel Kurulum** seçeneklerinden birini tercih edebilirsiniz.

### 🐳 Seçenek 1: Docker ile Veritabanı Kurulumu 

Bu proje kapsamında Docker, yalnızca PostgreSQL veritabanını hızlıca ayağa kaldırmak için kullanılmaktadır (backend servisi Docker'a dahil değildir, lokal olarak `npm run dev` ile çalıştırılır).

Proje kök dizininde:

```bash
docker-compose up -d
```

Bu komut, yerel geliştirme ortamı (local environment) için yapılandırılmış varsayılan kimlik bilgileriyle (kullanıcı: root, şifre: rootpassword) localhost:5432 üzerinde izole bir PostgreSQL veritabanı başlatır. `.env` dosyanızı oluştururken `DATABASE_URL` alanındaki kullanıcı adı ve şifre yer tutucularını (`kullanici_adi:sifre`) `root:rootpassword` değerleriyle değiştirmeniz yeterlidir.

Veritabanı ayağa kalktıktan sonra backend kurulumuna devam edin (bkz. "Seçenek 2: Manuel Kurulum" — 1. adımdan (`npm install`) itibaren aynı adımları izleyin, sadece kendi lokal PostgreSQL'inizi kurmanıza gerek kalmaz).

### 💻 Seçenek 2: Manuel Kurulum

`backend` klasörüne gidin ve bağımlılıkları yükleyin:

```bash
npm install
```

`.env.example` dosyasını `.env` olarak kopyalayın ve kendi PostgreSQL bağlantı bilgilerinizi girin.

Veritabanı tablolarını oluşturun ve seed verilerini yükleyin:

```bash
npx prisma migrate dev
npx prisma db seed
```

Sunucuyu başlatın:

```bash
npm run dev
```

Birim testlerini çalıştırmak için:

```bash
npm test
```

---

## 📱 Frontend (Flutter) Kurulumu

`frontend` klasörüne gidin:

```bash
cd frontend
```

Gerekli paketleri yükleyin:

```bash
flutter pub get
```

Uygulamayı çalıştırın:

```bash
flutter run
```

> **Not:** Backend varsayılan olarak `http://localhost:3000` adresinde çalışmaktadır. Gerçek cihaz kullanıyorsanız Flutter uygulamasındaki API adresini kendi bilgisayarınızın yerel IP adresiyle güncellemeniz gerekir.

---

## 👩‍💻 Geliştirici

**Sinem Ertural**
