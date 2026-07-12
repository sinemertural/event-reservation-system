import { Router } from 'express';
import * as authController from '../controllers/auth.controller';

const router = Router();

// POST isteği ile '/register' adresine gelindiğinde, işlemi authController.register fonksiyonuna devret
router.post('/register', authController.register);

export default router;