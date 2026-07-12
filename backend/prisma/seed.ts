import prisma from '../src/config/prisma';

async function main() {
  console.log('Seed işlemi başlıyor...');

  await prisma.event.deleteMany(); // DELETE  FROM event; tüm etkinlik kayıtlarını siler. sebebi: seed işlemi sırasında tekrar tekrar çalıştırıldığında aynı verilerin eklenmesini önlemek için.
  console.log('Eski etkinlik kayıtları temizlendi.');

  // Veritabanına basılacak 10 adet örnek etkinlik
  const eventsData = [
    { 
      title: 'Web Geliştirme Zirvesi', 
      description: 'Modern web teknolojileri, React ve Node.js üzerine kapsamlı bir zirve.', 
      date: new Date('2026-08-15T10:00:00Z'), 
      total_quota: 100, 
      available_quota: 100 
    },
    { 
      title: 'Bursa Mobil Yazılım Atölyesi', 
      description: 'Flutter ve Kotlin kullanarak uçtan uca mobil uygulama geliştirme temelleri.', 
      date: new Date('2026-08-20T14:00:00Z'), 
      total_quota: 50, 
      available_quota: 50 
    },
    { 
      title: 'Temiz Kod ve SOLID Prensipleri', 
      description: 'Bağımsız projelerde sürdürülebilir ve temiz kod yazma teknikleri.', 
      date: new Date('2026-09-01T10:00:00Z'), 
      total_quota: 40, 
      available_quota: 40 
    },
    { 
      title: 'Çocuklar İçin Oyun Programlama Şenliği', 
      description: 'Çocuklara yönelik temel algoritma mantığı ve interaktif oyun tasarımı.', 
      date: new Date('2026-09-15T11:00:00Z'), 
      total_quota: 30, 
      available_quota: 30 
    },
    { 
      title: 'Yapay Zeka ve Yazılım Teknolojileri', 
      description: 'Yazılım projelerinde yapay zeka asistanlarının aktif kullanımı.', 
      date: new Date('2026-09-10T15:00:00Z'), 
      total_quota: 150, 
      available_quota: 150 
    },
    { 
      title: 'Backend Mimarileri Eğitimi', 
      description: 'Veritabanı tasarımı, ORM araçları ve güvenli API geliştirme süreçleri.', 
      date: new Date('2026-09-05T09:30:00Z'), 
      total_quota: 60, 
      available_quota: 60 
    },
    { 
      title: 'DevOps ve Otomasyon Süreçleri', 
      description: 'Docker, Git yönetimi ve sürekli entegrasyon (CI/CD) kavramları.', 
      date: new Date('2026-09-20T10:00:00Z'), 
      total_quota: 80, 
      available_quota: 80 
    },
    { 
      title: 'Finansal Teknolojilerde Kariyer', 
      description: 'Büyük ölçekli kurumsal yetenek yönetimi programları ve işe alım süreçleri.', 
      date: new Date('2026-09-25T14:00:00Z'), 
      total_quota: 120, 
      available_quota: 120 
    },
    { 
      title: 'Veri Yapıları ve Algoritmalar', 
      description: 'Teknik mülakatlara hazırlık ve problem çözme yaklaşımları.', 
      date: new Date('2026-09-30T09:00:00Z'), 
      total_quota: 200, 
      available_quota: 200 
    },
    { 
      title: 'Start-up ve Girişimcilik Paneli', 
      description: 'Sıfırdan ürün çıkarma, pazar analizi ve yatırım alma süreçleri.', 
      date: new Date('2026-10-05T13:00:00Z'), 
      total_quota: 75, 
      available_quota: 75 
    }
  ];

  // Verileri döngü ile veritabanına ekle
  for (const event of eventsData) {
    await prisma.event.create({ // INSERT işlemi gerçekleştirir. event tablosuna yeni bir kayıt ekler.
      data: event,
    });
  }

  console.log('10 örnek etkinlik başarıyla eklendi.');
}

main() 
  .catch((e) => {
    console.error(e);
    process.exit(1); // exit(0) program başarıyla bitti, exit(1) program bir hata ile karşılaştı ve başarısız oldu anlamına gelir.
  })
  .finally(async () => {
    await prisma.$disconnect(); // Veritabanı bağlantısını kapatır. Kapanmazsa, seed işlemi tamamlandıktan sonra uygulama kapanmaz ve işlem sonsuz döngüye girer.
  });