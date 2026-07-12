import prisma from '../config/prisma';

export const getAllEvents = async (page: number = 1, limit: number = 10, dateFilter?: string) => {
  // 1. Pagination (Sayfalama) Hesaplamaları
  const skip = (page - 1) * limit; // Örneğin page=1 limit=10 ise (1-1) * 10 = 0 yani skip = 0  bunun anlamı ilk kayıttan başla demek. page=2 limit=10 ise (2-1) * 10 = 10 yani skip = 10 bunun anlamı 10 kayıt atla demek.

  // 2. Filtreleme (Filtering) Şartları
  const whereCondition: any = {}; // başlangıçta boş bir filtreleme var. yani SELECT * FROM event , tüm kayıtları getir.

  if (dateFilter) { // mesela uygulamadan 2026-09-10 gibi bir tarih gelirse
    const startDate = new Date(dateFilter); // oluşan tarih 2026-09-10 
    startDate.setUTCHours(0, 0, 0, 0); // oluşan tarih 2026-09-10 saat 00:00:00 (başlangıç)

    const endDate = new Date(startDate);
    endDate.setUTCHours(23, 59, 59, 999); // oluşan tarih 2026-09-10 saat 23:59:59 (bitiş)

    whereCondition.date = {
      gte: startDate, // Büyük veya eşit (Greater than or equal) (>=)
      lte: endDate,   // Küçük veya eşit (Less than or equal) (<=)
    };
  }


  const [events, totalRecords] = await Promise.all([ // Promise.all kullanma sebebi bir yandan events verileri getirilirken bir yandan count işlem görür. bekleme olmaz.
    prisma.event.findMany({ // SELECT * FROM event WHERE ... LIMIT ... OFFSET ... ORDER BY date ASC
      where: whereCondition, // filtre varsa onu uygular yoksa hepsini getirir.
      skip: skip, // ilk kaç kayıt alacak
      take: limit, // toplam kaç kayıt alacak
      orderBy: { date: 'asc' }, // Tarihe göre yakından uzağa sırala
    }),
    prisma.event.count({ // SELECT COUNT(*) FROM event WHERE ...
      where: whereCondition,
    }),
  ]);

  // 4. Sonucu Düzenleyip Döndürme
  return {
    data: events, // data: etkinlik verileri , meta: sayfalama bilgileri
    meta: { 
      total: totalRecords, // toplam kayıt
      page: page, // bulunduğun sayfa
      limit: limit, // sayfa başına kayıt sayısı
      totalPages: Math.ceil(totalRecords / limit), // toplam sayfa sayısı, Math.ceil ile yukarı yuvarlama yapıyoruz. Örn: 25 kayıt var ve limit=10 ise 25/10=2.5 yani 3 sayfa olacak.
    },
  };
};