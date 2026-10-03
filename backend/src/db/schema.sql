CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(120) NOT NULL,
  last_name VARCHAR(120) NOT NULL,
  role VARCHAR(32) NOT NULL CHECK (role IN ('owner', 'manager', 'cashier')),
  active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS business_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_name VARCHAR(255) NOT NULL,
  currency_code VARCHAR(10) NOT NULL DEFAULT 'ZAR',
  timezone VARCHAR(64) NOT NULL DEFAULT 'Africa/Johannesburg',
  vat_enabled BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pos_terminals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(120) NOT NULL,
  location VARCHAR(255),
  active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_pos_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  pos_terminal_id UUID NOT NULL REFERENCES pos_terminals(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, pos_terminal_id)
);

CREATE TABLE IF NOT EXISTS product_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(120) NOT NULL,
  description TEXT,
  active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS suppliers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  contact_name VARCHAR(255),
  phone VARCHAR(80),
  email VARCHAR(255),
  address TEXT,
  active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  sku VARCHAR(120) NOT NULL UNIQUE,
  category_id UUID REFERENCES product_categories(id),
  description TEXT,
  active BOOLEAN NOT NULL DEFAULT true,
  case_size INTEGER NOT NULL DEFAULT 24,
  pack_size INTEGER NOT NULL DEFAULT 6,
  selling_price_case NUMERIC(12,2) NOT NULL DEFAULT 0,
  selling_price_pack NUMERIC(12,2) NOT NULL DEFAULT 0,
  selling_price_single NUMERIC(12,2) NOT NULL DEFAULT 0,
  buying_price_case NUMERIC(12,2) NOT NULL DEFAULT 0,
  buying_price_pack NUMERIC(12,2) NOT NULL DEFAULT 0,
  buying_price_single NUMERIC(12,2) NOT NULL DEFAULT 0,
  returnable_empty BOOLEAN NOT NULL DEFAULT false,
  empty_type VARCHAR(32) DEFAULT 'Other',
  empty_value NUMERIC(12,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS product_price_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  selling_price_case NUMERIC(12,2) NOT NULL,
  selling_price_pack NUMERIC(12,2) NOT NULL,
  selling_price_single NUMERIC(12,2) NOT NULL,
  buying_price_case NUMERIC(12,2) NOT NULL,
  buying_price_pack NUMERIC(12,2) NOT NULL,
  buying_price_single NUMERIC(12,2) NOT NULL,
  effective_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS stock_periods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(120) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'BALANCING', 'BALANCED', 'CLOSED')),
  responsible_user_id UUID REFERENCES users(id),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS stock_balances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stock_period_id UUID NOT NULL REFERENCES stock_periods(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  opening_stock INTEGER NOT NULL DEFAULT 0,
  stock_received INTEGER NOT NULL DEFAULT 0,
  stock_in_adjustments INTEGER NOT NULL DEFAULT 0,
  stock_sold_cases INTEGER NOT NULL DEFAULT 0,
  stock_sold_packs INTEGER NOT NULL DEFAULT 0,
  stock_sold_singles INTEGER NOT NULL DEFAULT 0,
  stock_out_adjustments INTEGER NOT NULL DEFAULT 0,
  physical_closing_stock INTEGER NOT NULL DEFAULT 0,
  expected_closing_stock INTEGER NOT NULL DEFAULT 0,
  variance INTEGER NOT NULL DEFAULT 0,
  stock_sold_value NUMERIC(12,2) NOT NULL DEFAULT 0,
  empty_value NUMERIC(12,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(stock_period_id, product_id)
);

CREATE TABLE IF NOT EXISTS stock_receipts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  receipt_date DATE NOT NULL,
  supplier_id UUID REFERENCES suppliers(id),
  invoice_number VARCHAR(120),
  delivery_note_number VARCHAR(120),
  received_by VARCHAR(120),
  notes TEXT,
  status VARCHAR(32) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'CONFIRMED', 'REJECTED')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS stock_receipt_lines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stock_receipt_id UUID NOT NULL REFERENCES stock_receipts(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  cases_received INTEGER NOT NULL DEFAULT 0,
  packs_received INTEGER NOT NULL DEFAULT 0,
  singles_received INTEGER NOT NULL DEFAULT 0,
  total_quantity_singles INTEGER NOT NULL DEFAULT 0,
  buying_price_case NUMERIC(12,2) NOT NULL DEFAULT 0,
  buying_price_pack NUMERIC(12,2) NOT NULL DEFAULT 0,
  buying_price_single NUMERIC(12,2) NOT NULL DEFAULT 0,
  total_purchase_value NUMERIC(12,2) NOT NULL DEFAULT 0,
  free_cases INTEGER NOT NULL DEFAULT 0,
  free_packs INTEGER NOT NULL DEFAULT 0,
  free_singles INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS stock_adjustments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  adjustment_date DATE NOT NULL,
  product_id UUID NOT NULL REFERENCES products(id),
  adjustment_type VARCHAR(64) NOT NULL,
  direction VARCHAR(8) NOT NULL CHECK (direction IN ('IN', 'OUT')),
  quantity INTEGER NOT NULL DEFAULT 0,
  packaging_unit VARCHAR(32) NOT NULL,
  reason TEXT NOT NULL,
  notes TEXT,
  reference_number VARCHAR(120),
  recorded_by UUID NOT NULL REFERENCES users(id),
  approval_status VARCHAR(32) NOT NULL DEFAULT 'PENDING' CHECK (approval_status IN ('PENDING', 'APPROVED', 'REJECTED')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS customer_exchanges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exchange_date DATE NOT NULL,
  returned_product_id UUID NOT NULL REFERENCES products(id),
  returned_quantity INTEGER NOT NULL DEFAULT 0,
  replacement_product_id UUID NOT NULL REFERENCES products(id),
  replacement_quantity INTEGER NOT NULL DEFAULT 0,
  reason TEXT,
  handled_by UUID NOT NULL REFERENCES users(id),
  notes TEXT,
  price_difference NUMERIC(12,2) NOT NULL DEFAULT 0,
  difference_type VARCHAR(20) NOT NULL DEFAULT 'NONE' CHECK (difference_type IN ('REFUND', 'ADDITIONAL_PAYMENT', 'NONE')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS empty_movements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  movement_date DATE NOT NULL,
  product_id UUID NOT NULL REFERENCES products(id),
  movement_type VARCHAR(64) NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cash_movements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  movement_date DATE NOT NULL,
  pos_terminal_id UUID REFERENCES pos_terminals(id),
  movement_type VARCHAR(8) NOT NULL CHECK (movement_type IN ('IN', 'OUT')),
  description VARCHAR(255) NOT NULL,
  amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  recorded_by UUID NOT NULL REFERENCES users(id),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS expense_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(120) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_date DATE NOT NULL,
  pos_terminal_id UUID REFERENCES pos_terminals(id),
  name VARCHAR(255) NOT NULL,
  category_id UUID REFERENCES expense_categories(id),
  amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  payment_method VARCHAR(64) NOT NULL,
  description TEXT,
  recorded_by UUID NOT NULL REFERENCES users(id),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS safes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(120) NOT NULL,
  location VARCHAR(255),
  opening_balance NUMERIC(12,2) NOT NULL DEFAULT 0,
  responsible_user_id UUID REFERENCES users(id),
  active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS safe_movements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  movement_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  safe_id UUID NOT NULL REFERENCES safes(id) ON DELETE CASCADE,
  movement_type VARCHAR(32) NOT NULL,
  amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  description TEXT,
  reference_number VARCHAR(120),
  recorded_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS bank_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  bank_name VARCHAR(255),
  account_number VARCHAR(64),
  active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS banking_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  banking_date DATE NOT NULL,
  pos_terminal_id UUID REFERENCES pos_terminals(id),
  banking_type VARCHAR(64) NOT NULL,
  amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  bank_account_id UUID REFERENCES bank_accounts(id),
  reference_number VARCHAR(120),
  person_banking UUID NOT NULL REFERENCES users(id),
  proof_url TEXT,
  notes TEXT,
  status VARCHAR(32) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'BANKED', 'CONFIRMED')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS card_settlements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  settlement_date DATE NOT NULL,
  pos_terminal_id UUID REFERENCES pos_terminals(id),
  settlement_reference VARCHAR(255) NOT NULL,
  settlement_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  bank_account_id UUID REFERENCES bank_accounts(id),
  status VARCHAR(32) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'BANKED', 'CONFIRMED')),
  recorded_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pos_daily_balances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  balance_date DATE NOT NULL,
  pos_terminal_id UUID NOT NULL REFERENCES pos_terminals(id),
  opening_cash NUMERIC(12,2) NOT NULL DEFAULT 0,
  cash_sales NUMERIC(12,2) NOT NULL DEFAULT 0,
  card_sales NUMERIC(12,2) NOT NULL DEFAULT 0,
  other_cash_in NUMERIC(12,2) NOT NULL DEFAULT 0,
  other_cash_out NUMERIC(12,2) NOT NULL DEFAULT 0,
  expenses NUMERIC(12,2) NOT NULL DEFAULT 0,
  expected_closing_cash NUMERIC(12,2) NOT NULL DEFAULT 0,
  actual_closing_cash NUMERIC(12,2) NOT NULL DEFAULT 0,
  cash_variance NUMERIC(12,2) NOT NULL DEFAULT 0,
  dropped_to_safe NUMERIC(12,2) NOT NULL DEFAULT 0,
  cash_back_to_banking NUMERIC(12,2) NOT NULL DEFAULT 0,
  cash_remaining NUMERIC(12,2) NOT NULL DEFAULT 0,
  banking_status VARCHAR(32) NOT NULL DEFAULT 'OPEN' CHECK (banking_status IN ('OPEN', 'PENDING', 'BANKED', 'CONFIRMED')),
  status VARCHAR(32) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'BALANCING', 'BALANCED', 'CLOSED')),
  created_by UUID NOT NULL REFERENCES users(id),
  closed_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS period_reconciliations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stock_period_id UUID NOT NULL REFERENCES stock_periods(id),
  stock_sold_value NUMERIC(12,2) NOT NULL DEFAULT 0,
  cash_accounted NUMERIC(12,2) NOT NULL DEFAULT 0,
  card_accounted NUMERIC(12,2) NOT NULL DEFAULT 0,
  other_accounted NUMERIC(12,2) NOT NULL DEFAULT 0,
  total_accounted NUMERIC(12,2) NOT NULL DEFAULT 0,
  difference NUMERIC(12,2) NOT NULL DEFAULT 0,
  reviewed BOOLEAN NOT NULL DEFAULT false,
  reviewed_by UUID REFERENCES users(id),
  review_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  action VARCHAR(255) NOT NULL,
  module_name VARCHAR(120) NOT NULL,
  record_id VARCHAR(120),
  previous_value JSONB,
  new_value JSONB,
  reason TEXT,
  approver_id UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payment_methods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(120) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS approval_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requires_approval_for_large_adjustments BOOLEAN NOT NULL DEFAULT true,
  large_adjustment_threshold NUMERIC(12,2) NOT NULL DEFAULT 5000,
  require_approval_for_price_changes BOOLEAN NOT NULL DEFAULT true,
  require_approval_for_reopening_closed_periods BOOLEAN NOT NULL DEFAULT true,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS stock_period_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  default_period_length_days INTEGER NOT NULL DEFAULT 7,
  lock_closed_periods BOOLEAN NOT NULL DEFAULT true,
  require_reason_for_corrections BOOLEAN NOT NULL DEFAULT true,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_stock_receipt_lines_product_id ON stock_receipt_lines(product_id);
CREATE INDEX IF NOT EXISTS idx_stock_adjustments_product_id ON stock_adjustments(product_id);
CREATE INDEX IF NOT EXISTS idx_pos_daily_balances_date ON pos_daily_balances(balance_date);
CREATE INDEX IF NOT EXISTS idx_banking_transactions_date ON banking_transactions(banking_date);
CREATE INDEX IF NOT EXISTS idx_audit_logs_module ON audit_logs(module_name);
