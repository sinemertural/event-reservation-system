import { Request, Response } from 'express';
import * as authService from '../services/auth.service';
import { AuthRequest } from '../middlewares/auth.middleware';

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

export const login = async (req: Request, res: Response): Promise<void> => {
  try {
    // gelen istekten e-posta ve şifreyi al
    const { email, password } = req.body;

    // alanlar boş ise 400 (Bad Request) dön
    if (!email || !password) {
      res.status(400).json({
        success: false,
        message: 'Lütfen e-posta ve şifre alanlarını eksiksiz doldurun.',
      });
      return;
    }

    // bilgilerin doğrulanması için servis katmanına gönder
    const result = await authService.loginUser(email, password);

    // her şey doğru ise 200 (OK) dön ve token ile kullanıcı bilgilerini gönder
    res.status(200).json({
      success: true,
      message: 'Giriş işlemi başarıyla tamamlandı.',
      data: result, // İçinde 'user' ve 'token' var. buradaki token mobil uygulama kodlanırken buradaki token cihaz hafızasında saklanacak.
    });

  } catch (error: any) {
    // şifre yanlış veya kullanıcı bulunamadı ise 401 (Unauthorized) dön.
    res.status(401).json({
      success: false,
      message: error.message || 'Giriş yapılamadı.',
    });
  }
};

export const getProfile = async (req: AuthRequest, res: Response): Promise<void> => { 
  res.status(200).json({
    success: true,
    message: 'Korumalı alana hoşgeldin. Kimlik doğrulaması başarılı.',
    data: req.user, // requireAuth middleware'inden gelen kullanıcı bilgisi. req.body den almıyoruz çünkü auth.middleware'de token doğrulandıktan sonra req.user alanına kullanıcı bilgisi ekleniyor.
  });
}