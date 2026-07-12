import { Request, Response } from 'express';
import * as eventService from '../services/event.service';

export const getEvents = async (req: Request, res: Response): Promise<void> => {
  try {
    // istekten gelen query parametrelerini alıyoruz. Bunlar sayfa numarası, sayfa başına kayıt sayısı ve tarih filtresi olabilir. String'e çevirmeliyiz.
    const pageStr = req.query.page as string;
    const limitStr = req.query.limit as string;
    const dateStr = req.query.date as string;

    // gelen değerleri sayısal değerlere çeviriyoruz. Eğer değer yoksa undefined olarak bırakıyoruz. Undefined giderse servis varsayılan değer (page=1, limit=10) kullanacak.
    const page = pageStr ? parseInt(pageStr, 10) : undefined;
    const limit = limitStr ? parseInt(limitStr, 10) : undefined;

    //veriyi getirmesi için Servis katmanına emir veriyoruz
    const result = await eventService.getAllEvents(page, limit, dateStr);

    // gelen veriyi standart formatımızda dışarıya sunuyoruz
    res.status(200).json({
      success: true,
      message: 'Etkinlikler başarıyla getirildi.',
      data: result.data,
      meta: result.meta,
    });
    
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Etkinlikler getirilirken bir hata oluştu.',
    });
  }
};