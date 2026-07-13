import { Router } from 'express';
import * as reservationController from '../controllers/reservation.controller';
import { requireAuth } from '../middlewares/auth.middleware';

const router = Router();

// POST isteği ile '/' adresine gelindiğinde, önce requireAuth middleware'i çalıştırılır. Eğer kullanıcı doğrulanırsa, işlemi reservationController.createReservation fonksiyonuna devret
router.post('/', requireAuth, reservationController.createReservation);

export default router;