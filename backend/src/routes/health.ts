import { Router } from 'express';
import { pool } from '../db.js';

export const healthRouter = Router();

healthRouter.get('/', async (_req, res) => {
  try {
    const result = await pool.query('SELECT NOW() AS current_time');
    res.json({
      status: 'ok',
      timestamp: result.rows[0].current_time,
      timezone: 'Africa/Johannesburg',
      database: 'postgresql',
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Database unavailable',
      error: error instanceof Error ? error.message : 'unknown error',
    });
  }
});
