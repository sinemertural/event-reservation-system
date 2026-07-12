import { Router } from 'express';
import * as authController from '../controllers/auth.controller';
import { requireAuth } from '../middlewares/auth.middleware';

const router = Router();

// POST isteği ile '/register' adresine gelindiğinde, işlemi authController.register fonksiyonuna devret
router.post('/register', authController.register);

// POST isteği ile '/login' adresine gelindiğinde, işlemi authController.login fonksiyonuna devret
router.post('/login', authController.login);

// GET isteği ile '/me' adresine gelindiğinde, önce requireAuth middleware'i çalıştırılır. Eğer kullanıcı doğrulanırsa, işlemi authController.getProfile fonksiyonuna devret
router.get('/me', requireAuth, authController.getProfile);

export default router;