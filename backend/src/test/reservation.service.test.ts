import { createReservation } from '../services/reservation.service'; 
import prisma from '../config/prisma';

// 1. Prisma'yı sahte (mock) bir objeye dönüştürüyoruz
jest.mock('../config/prisma', () => ({
  __esModule: true,
  default: {
    $transaction: jest.fn(),
  }
}));

describe('Rezervasyon İş Mantığı (Create Reservation)', () => {
  let mockTx: any;

  beforeEach(() => {
    // Her testten önce eski çağrıları temizle
    jest.clearAllMocks();

    // 2. Transaction içindeki 'tx' objesini taklit ediyoruz
    mockTx = {
      event: {
        updateMany: jest.fn(),
      },
      reservation: {
        create: jest.fn(),
      },
    };

    // Prisma'nın $transaction fonksiyonunun, bizim sahte 'tx' objemizle çalışmasını sağlıyoruz
    (prisma.$transaction as jest.Mock).mockImplementation(async (callback) => {
      return await callback(mockTx);
    });
  });

  test('Kontenjan yeterliyse rezervasyon başarıyla oluşturulmalı', async () => {
    // Arrange (Hazırlık): updateMany başarılı olsun ve 1 kayıt güncellesin
    mockTx.event.updateMany.mockResolvedValue({ count: 1 });
    mockTx.reservation.create.mockResolvedValue({ id: 'res-123', event_id: 'evt-1', guest_count: 2 });

    // Act (Eylem): Fonksiyonu çağır
    const result = await createReservation('user-1', 'evt-1', 2);

    // Assert (İddia): Doğru fonksiyonlar, doğru parametrelerle çağrıldı mı?
    expect(mockTx.event.updateMany).toHaveBeenCalledWith({
      where: {
        id: 'evt-1',
        available_quota: { gte: 2 }, // En az 2 kontenjan olmalı şartı
      },
      data: {
        available_quota: { decrement: 2 }, // 2 kontenjan düşüldü mü?
      },
    });
    expect(mockTx.reservation.create).toHaveBeenCalled();
    expect(result.id).toBe('res-123');
  });

  test('İstenen kişi sayısı kalan kontenjandan fazlaysa (Overbooking) hata fırlatmalı', async () => {
    // Arrange: updateMany başarısız olsun (0 kayıt güncellendi)
    mockTx.event.updateMany.mockResolvedValue({ count: 0 });

    // Act & Assert: Fonksiyonun hata fırlatmasını bekle
    await expect(createReservation('user-1', 'evt-1', 5))
      .rejects
      .toThrow('Yetersiz kontenjan veya etkinlik bulunamadı.');

    // En kritik test: Hata fırladığı için bilet kesme işlemi HİÇ ÇAĞRILMAMALI!
    expect(mockTx.reservation.create).not.toHaveBeenCalled();
  });
});