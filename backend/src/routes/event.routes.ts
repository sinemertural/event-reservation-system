import { Router } from 'express';
import * as eventController from '../controllers/event.controller';

const router = Router();

// GET isteği ile '/events' adresine gelindiğinde, işlemi eventController.getEvents fonksiyonuna devret
router.get('/', eventController.getEvents);

export default router;