import { Router } from 'express';
import * as reservationController from '../controllers/reservation.controller';
import { requireAuth } from '../middlewares/auth.middleware';

const router = Router();

// Endpoint: GET /api/reservations/me
// (Kullanıcının kendi rezervasyonlarını getirir - Token zorunlu)
router.get('/me', requireAuth, reservationController.getMyReservations);

// Endpoint: POST /api/reservations
// (Yeni rezervasyon oluşturur - Token zorunlu)
router.post('/', requireAuth, reservationController.createReservation);

// Endpoint: DELETE /api/reservations/:id
// (Rezervasyonu iptal eder - Token zorunlu)
router.delete('/:id', requireAuth, reservationController.deleteReservation);

export default router;