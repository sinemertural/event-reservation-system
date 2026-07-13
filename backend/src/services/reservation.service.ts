import prisma from '../config/prisma';

export const createReservation = async (userId: string, eventId: string, guestCount: number) => {

  return await prisma.$transaction(async (tx) => { // transaction fonksiyonu, birden fazla veritabanı işlemini tek bir işlem olarak yürütmemizi sağlar. Eğer bu işlemlerden biri başarısız olursa, tüm işlemler geri alınır (rollback).
    
    // atomik güncelleme işlemi
    const updatedEvent = await tx.event.updateMany({ // updateMany, birden fazla kaydı güncelleyebilir. Ancak biz burada sadece bir kaydı güncellemek istiyoruz. Fakat "where" şartına birden fazla koşul ekleyebilmek için updateMany kullanıyoruz.
      where: {
        id: eventId,
        available_quota: {
          gte: guestCount, //Kalan kontenjan, istenen kişi sayısından büyük veya EŞİT olmalı!
        },
      },
      data: {
        available_quota: {
          decrement: guestCount, //Şart sağlanıyorsa kontenjanı anında kişi sayısı kadar düş.
        },
      },
    }); // bu fonksiyon tek bir SQL sorgusu olarak çalışır ve güncellenen kayıt sayısını döndürür. 

    // Eğer count 0 dönerse, bu etkinliğin ya ID'si yanlıştır ya da KONTENJANI YETERSİZDİR.
    if (updatedEvent.count === 0) {
      throw new Error('Yetersiz kontenjan veya etkinlik bulunamadı.');
    }

    // Yukarıdaki şart başarıyla geçildiyse ve kontenjan düşüldüyse, artık gönül rahatlığıyla rezervasyon belgesini kesebiliriz.
    const newReservation = await tx.reservation.create({
      data: {
        user_id: userId,
        event_id: eventId,
        guest_count: guestCount, 
      },
    });

    return newReservation;
  });
};

export const getUserReservations = async (userId: string) => {
  const reservations = await prisma.reservation.findMany({
    where: { 
      user_id: userId 
    },
    include: {
      event: true, // Rezervasyonla ilişkili etkinlik bilgilerini de getir(Mobil Uygulama için)
    },
    orderBy: { 
      createdAt: 'desc' // En son alınan bileti en üstte göster
    },
  });

  return reservations;
};

export const cancelReservation = async (userId: string, reservationId: string) => {
  // önce rezervasyonu bulalım 
  const existingReservation = await prisma.reservation.findUnique({
    where: { id: reservationId },
  });

  // Eğer böyle bir rezervasyon yoksa işlemi kes
  if (!existingReservation) {
    throw new Error('Rezervasyon bulunamadı.');
  }

  // Kullanıcı başkasının biletini mi iptal etmeye çalışıyor?
  if (existingReservation.user_id !== userId) {
    throw new Error('Bu rezervasyonu iptal etme yetkiniz yok.');
  }

  // 2. Transaction başlatıyoruz çünkü silme ve kontenjanı geri açma işlemlerini tek bir işlem olarak yapmak istiyoruz. Eğer biri başarısız olursa, diğerini de geri alacağız.
  return await prisma.$transaction(async (tx) => {
    // rezervasyonu sil
    const deletedReservation = await tx.reservation.delete({
      where: { id: reservationId },
    });

    // etkinliğin kontenjanını geri aç (increment)
    await tx.event.update({
      where: { id: existingReservation.event_id },
      data: {
        available_quota: {
          increment: existingReservation.guest_count, // kaç bilet aldıysa o kadar kontenjanı geri aç
        },
      },
    });

    return deletedReservation;
  });
};