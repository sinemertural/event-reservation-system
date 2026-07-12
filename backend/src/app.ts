import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import authRoutes from './routes/auth.routes';
import eventRoutes from './routes/event.routes';

const app: Application = express();

//Middlewares (Ara Katmanlar)
app.use(cors());
app.use(express.json());
app.use('/api/auth', authRoutes); //'/api/auth' ile başlayan tüm istekleri authRoutes dosyamıza yönlendir
app.use('/api/events', eventRoutes); //'/api/events' ile başlayan tüm istekleri eventRoutes dosyamıza yönlendir

//Healty check
app.get('/ping', (req: Request, res: Response) => {
    res.status(200).json({ success: true, message: 'pong' });
});

// Ana sayfa karşılama mesajı
app.get('/', (req: Request, res: Response) => {
    res.status(200).json({ 
        success: true, 
        message: 'Etkinlik Rezervasyon API sistemine hoş geldiniz!' 
    });
});

export default app;