import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import authRoutes from './routes/auth.routes';

const app: Application = express();

//Middlewares (Ara Katmanlar)
app.use(cors());
app.use(express.json());
app.use('/api/auth', authRoutes); //'/api/auth' ile başlayan tüm istekleri authRoutes dosyamıza yönlendir

//Healty check
app.get('/ping', (req: Request, res: Response) => {
    res.status(200).json({ success: true, message: 'pong' });
});

export default app;