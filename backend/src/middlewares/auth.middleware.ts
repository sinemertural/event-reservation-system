import { Request, Response, NextFunction } from 'express'; // next fonksiyonu ile middleware zincirinde bir sonraki middleware'e geçiş yapabiliriz
import jwt from 'jsonwebtoken';

// TypeScript'te Request objesinde normalde user alanı yok biz genişleterek AuthRequest interface'ini oluşturuyoruz. Bu sayede requireAuth middleware'inde user alanını kullanabiliriz.
export interface AuthRequest extends Request {
  user?: any;
}

export const requireAuth = (req: AuthRequest, res: Response, next: NextFunction): void => {
  
  const authHeader = req.headers.authorization; // Authorization header'ını alıyoruz. Bu header genellikle "Bearer <token>" formatında olur.

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({ success: false, message: 'Yetkisiz erişim. Lütfen giriş yapın.' }); // 401 token yoksa
    return;
  }

  
  const token = authHeader.split(' ')[1]; // split(' ')[0] -> Bearer, split(' ')[1] -> token

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET as string); // jwt.verify ile token'ı doğruluyoruz. decoded token içindeki payload'ı içerir.

    req.user = decoded;

    next();
  } catch (error) {
    res.status(403).json({ success: false, message: 'Geçersiz veya süresi dolmuş token.' }); // 403 token sahte, değiştirilmiş veya süresi dolmuşsa
  }
};