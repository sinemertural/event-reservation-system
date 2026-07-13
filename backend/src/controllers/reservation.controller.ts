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