import { Router } from 'express';
import * as eventController from '../controllers/event.controller';

const router = Router();

// Tüm etkinlikleri listele (Sayfalama ve Filtreleme ile)
router.get('/', eventController.getEvents);

// Belirli bir etkinliği getir
router.get('/:id', eventController.getEvent);

export default router;