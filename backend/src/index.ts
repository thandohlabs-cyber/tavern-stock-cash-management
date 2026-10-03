import express from 'express';
import type { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { createDbPool } from './db.js';
import { healthRouter } from './routes/health.js';

dotenv.config();

const app = express();
const PORT = Number(process.env.PORT ?? 4000);

app.use(
  helmet({
    crossOriginResourcePolicy: false,
  }),
);

app.use(
  cors({
    origin: process.env.CLIENT_URL ?? true,
    credentials: true,
  }),
);

app.use(express.json({ limit: '1mb' }));
app.use(morgan('dev'));

app.get('/api', (_req, res) => {
  res.json({
    name: 'Tavern Stock & Cash Management API',
    status: 'ready',
    timezone: 'Africa/Johannesburg',
    currency: 'ZAR',
  });
});

app.use('/api/health', healthRouter);

app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
  console.error(err.stack);
  res.status(500).json({
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'production' ? undefined : err.message,
  });
});

const startServer = async () => {
  const connected = await createDbPool();

  if (!connected) {
    console.warn('Database connection unavailable. Server starting in limited mode.');
  }

  app.listen(PORT, () => {
    console.log(`API listening on http://localhost:${PORT}`);
  });
};

startServer();
