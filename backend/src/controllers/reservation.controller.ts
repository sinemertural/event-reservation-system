import { Request, Response } from 'express';
import * as reservationService from '../services/reservation.service';

export const createReservation = async (req: Request, res: Response): Promise<void> => {
  try {
    // user_id bilgisini auth middleware'inin req objesine eklediği user'dan alıyoruz (JWT'den geliyor). TS hata vermesin diye any tipine çevirdik.
    const userId = (req as any).user.userId; 
    
    // Geri kalan bilgileri kullanıcının yolladığı body'den (JSON) alıyoruz
    const { event_id, guest_count } = req.body;

    // Gerekli alanların dolu olup olmadığını kontrol et
    if (!event_id || !guest_count || typeof guest_count !== 'number' || guest_count <= 0) {
      res.status(400).json({
        success: false,
        message: 'Lütfen geçerli bir etkinlik ID ve kişi sayısı (guest_count) giriniz.',
      });
      return;
    }

    // Rezervasyon oluşturma işlemini servis katmanına devret
    const reservation = await reservationService.createReservation(userId, event_id, guest_count);

    // 4. Başarılı yanıt dön
    res.status(201).json({
      success: true,
      message: 'Rezervasyon başarıyla oluşturuldu.',
      data: reservation,
    });

  } catch (error: any) {
    // Servisten gelen "Yetersiz kontenjan" hatasını yakalıyoruz
    if (error.message === 'Yetersiz kontenjan veya etkinlik bulunamadı.') {
      res.status(400).json({
        success: false,
        message: error.message,
      });
      return;
    }

    res.status(500).json({
      success: false,
      message: error.message || 'Rezervasyon oluşturulurken bir hata meydana geldi.',
    });
  }
};

export const getMyReservations = async (req: Request, res: Response): Promise<void> => {
  try {
    // tokendan kullanıcı ID'sini alıyoruz.
    const userId = (req as any).user.userId;

    if (!userId) {
      res.status(401).json({
        success: false,
        message: 'Kullanıcı kimliği okunamadı.',
      });
      return;
    }

    // 2. Servisi çağırıp biletleri getiriyoruz
    const reservations = await reservationService.getUserReservations(userId);

    // 3. Başarıyla yanıt dönüyoruz
    res.status(200).json({
      success: true,
      message: 'Rezervasyonlarınız başarıyla getirildi.',
      data: reservations,
    });

  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Rezervasyonlar getirilirken bir hata oluştu.',
    });
  }
};

export const deleteReservation = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    const reservationId = req.params.id as string;

    if (!userId) {
      res.status(401).json({
        success: false,
        message: 'Kullanıcı kimliği okunamadı.',
      });
      return;
    }

    // servisi çağırıpiptal ve kontenjan açma işlemini başlatıyoruz
    await reservationService.cancelReservation(userId, reservationId);

    res.status(200).json({
      success: true,
      message: 'Rezervasyon başarıyla iptal edildi ve kontenjan geri açıldı.',
    });

  } catch (error: any) {
    if (error.message === 'Rezervasyon bulunamadı.') {
      res.status(404).json({ success: false, message: error.message });
      return;
    }
    if (error.message === 'Bu rezervasyonu iptal etme yetkiniz yok.') {
      res.status(403).json({ success: false, message: error.message });
      return;
    }

    res.status(500).json({
      success: false,
      message: error.message || 'Rezervasyon iptal edilirken bir hata oluştu.',
    });
  }
};