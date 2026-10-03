# Tavern Stock & Cash Management System

This repository contains the foundation starter project for the tavern stock and cash management platform described in the project brief.

## Included foundation

- React + TypeScript + Vite frontend shell
- Express + TypeScript backend API
- PostgreSQL schema starter for the core financial system
- Role-based auth and business-domain structure
- Dashboard starter UI with financial summary cards
- Environment configuration and deployment-ready project layout

## Tech stack

- Frontend: React, TypeScript, Vite
- Backend: Node.js, TypeScript, Express
- Database: PostgreSQL
- Packaging: npm workspaces

## Repository layout

- `frontend/` – dashboard and UI shell
- `backend/` – API server and database schema
- `backend/src/db/schema.sql` – PostgreSQL foundation schema

## Quick start

1. Install dependencies:
   ```bash
   npm install
   ```

2. Copy the environment template:
   ```bash
   cp .env.example .env
   ```

3. Update `DATABASE_URL` and other environment values.

4. Start the backend:
   ```bash
   npm run dev:server
   ```

5. Start the frontend:
   ```bash
   npm run dev:client
   ```

6. Build the project:
   ```bash
   npm run build
   ```

## Notes

This is the foundation phase only. It includes the project structure, database schema, auth-ready API, and a working dashboard shell, but it does not yet implement every business module from the full specification.

The next implementation phases are:

1. Users and permissions
2. Product and stock management
3. POS and daily cash flow
4. Banking, card settlements, and reconciliations
5. Reports, exports, audit trail, and approvals
