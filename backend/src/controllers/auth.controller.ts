import { Request, Response } from 'express';
import * as authService from '../services/auth.service';

// Promise<void> ile asenkron bir işlem yapacak ve sonuç olarak herhangi bir değer döndürmeyecek.
export const register = async (req: Request, res: Response): Promise<void> => {
  try {
    // gelen isteğin body kısmından name, email ve password alanlarını alıyoruz
    const { name, email, password } = req.body;

    // doğrulama: name, email ve password alanlarının boş olup olmadığını kontrol ediyoruz
    if (!name || !email || !password) {
      res.status(400).json({ 
        success: false, 
        message: 'Lütfen isim, e-posta ve şifre alanlarını eksiksiz doldurun.' 
      });
      return;
    }

    // veriyi işi yapacak olan servis katmanına gönderiyoruz
    const newUser = await authService.registerUser(name, email, password);

    // işlem başarılı ise 201 Created statüsü ile birlikte kullanıcı bilgilerini döndürüyoruz
    res.status(201).json({
      success: true,
      message: 'Kullanıcı kaydı başarıyla tamamlandı.',
      data: newUser,
    });
    
  } catch (error: any) {
    // serviste bir hata oluşursa 400 Bad Request statüsü ile birlikte hata mesajını döndürüyoruz
    res.status(400).json({
      success: false,
      message: error.message || 'Kayıt işlemi sırasında beklenmeyen bir hata oluştu.',
    });
  }
};