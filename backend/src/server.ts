import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import authRoutes from './modules/auth/auth.routes';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5001;

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use('/api/v1/auth', authRoutes);

app.get('/', (_req, res) => {
    res.json({
        success: true,
        message: 'aurenConnect API is running',
    });
});

app.get('/api/v1/health', (_req, res) => {
    res.status(200).json({
        success: true,
        message: 'Server is healthy',
        timestamp: new Date().toISOString(),
    });
});

app.listen(PORT, () => {
    console.log(`aurenConnect API running on http://localhost:${PORT}`);
});