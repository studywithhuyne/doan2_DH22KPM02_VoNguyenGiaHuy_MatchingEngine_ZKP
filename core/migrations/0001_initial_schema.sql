-- Migration: 0001_schema  (consolidated — replaces 0001..0005)
-- Single source of truth for the entire CEX database schema + seed data.
-- The live matching engine runs 100% in-memory; these tables are used only
-- for async persistence (audit logs, balance snapshots, OHLCV candles).
--
-- Authentication: Argon2id password hash stored on the users table.
--                 Identity in dev/test is via the x-user-id header (u64).
--                 Ed25519 API-key auth is out of scope → no api_keys table.

-- ──────────────────────────────────────────────────────────────────────────────
-- ENUM TYPES
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TYPE order_side   AS ENUM ('buy', 'sell');
CREATE TYPE order_status AS ENUM ('open', 'partial', 'filled', 'cancelled');

-- ──────────────────────────────────────────────────────────────────────────────
-- TABLE: users
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS users (
    id            BIGINT      PRIMARY KEY,           -- x-user-id header value (u64)
    username      TEXT        NOT NULL UNIQUE,
    password_hash TEXT,                              -- Argon2id; NULL for legacy seed users
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ──────────────────────────────────────────────────────────────────────────────
-- TABLE: assets
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS assets (
    symbol     TEXT        PRIMARY KEY,           -- e.g. 'BTC', 'USDT'
    name       TEXT        NOT NULL,
    decimals   SMALLINT    NOT NULL DEFAULT 8,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ──────────────────────────────────────────────────────────────────────────────
-- TABLE: balances
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS balances (
    user_id      BIGINT        NOT NULL REFERENCES users(id),
    asset_symbol TEXT          NOT NULL REFERENCES assets(symbol),
    available    NUMERIC(30,8) NOT NULL DEFAULT 0,
    locked       NUMERIC(30,8) NOT NULL DEFAULT 0,
    updated_at   TIMESTAMPTZ   NOT NULL DEFAULT now(),

    PRIMARY KEY (user_id, asset_symbol),

    CONSTRAINT chk_available_ge_zero CHECK (available >= 0),
    CONSTRAINT chk_locked_ge_zero    CHECK (locked    >= 0)
);

-- ──────────────────────────────────────────────────────────────────────────────
-- TABLE: orders_log
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS orders_log (
    id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id    BIGINT        NOT NULL UNIQUE,    -- matches Order.id in the engine
    user_id     BIGINT        NOT NULL REFERENCES users(id),
    side        order_side    NOT NULL,
    price       NUMERIC(30,8) NOT NULL,
    amount      NUMERIC(30,8) NOT NULL,
    filled      NUMERIC(30,8) NOT NULL DEFAULT 0,
    status      order_status  NOT NULL DEFAULT 'open',
    base_asset  TEXT          NOT NULL,
    quote_asset TEXT          NOT NULL,
    created_at  TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ   NOT NULL DEFAULT now(),

    CONSTRAINT chk_price_positive  CHECK (price  > 0),
    CONSTRAINT chk_amount_positive CHECK (amount > 0),
    CONSTRAINT chk_filled_valid    CHECK (filled >= 0 AND filled <= amount)
);

-- ──────────────────────────────────────────────────────────────────────────────
-- TABLE: trades_log
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS trades_log (
    id             UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    maker_order_id BIGINT        NOT NULL REFERENCES orders_log(order_id),
    taker_order_id BIGINT        NOT NULL REFERENCES orders_log(order_id),
    maker_user_id  BIGINT        NOT NULL REFERENCES users(id),
    taker_user_id  BIGINT        NOT NULL REFERENCES users(id),
    price          NUMERIC(30,8) NOT NULL,
    amount         NUMERIC(30,8) NOT NULL,
    base_asset     TEXT          NOT NULL,
    quote_asset    TEXT          NOT NULL,
    executed_at    TIMESTAMPTZ   NOT NULL DEFAULT now(),

    CONSTRAINT chk_trade_price_positive  CHECK (price  > 0),
    CONSTRAINT chk_trade_amount_positive CHECK (amount > 0),
    CONSTRAINT chk_no_self_trade         CHECK (maker_user_id != taker_user_id)
);

-- ──────────────────────────────────────────────────────────────────────────────
-- TABLE: candles  (OHLCV)
-- Aggregated by the async persistence worker from TradeFilled events.
-- Supported intervals: 1m, 5m, 1h, 1d.
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS candles (
    symbol    TEXT          NOT NULL,           -- e.g. 'BTC_USDT'
    interval  TEXT          NOT NULL,           -- '1m' | '5m' | '1h' | '1d'
    open_time TIMESTAMPTZ   NOT NULL,           -- start of candle period (UTC, floored)
    open      NUMERIC(30,8) NOT NULL,
    high      NUMERIC(30,8) NOT NULL,
    low       NUMERIC(30,8) NOT NULL,
    close     NUMERIC(30,8) NOT NULL,
    volume    NUMERIC(30,8) NOT NULL,

    PRIMARY KEY (symbol, interval, open_time),

    CONSTRAINT chk_candle_open_positive   CHECK (open   > 0),
    CONSTRAINT chk_candle_high_ge_low     CHECK (high  >= low),
    CONSTRAINT chk_candle_volume_positive CHECK (volume > 0)
);

-- ──────────────────────────────────────────────────────────────────────────────
-- INDEXES
-- ──────────────────────────────────────────────────────────────────────────────

CREATE INDEX idx_orders_log_user_id           ON orders_log (user_id);
CREATE INDEX idx_orders_log_status            ON orders_log (status);
CREATE INDEX idx_trades_log_maker             ON trades_log (maker_user_id);
CREATE INDEX idx_trades_log_taker             ON trades_log (taker_user_id);
CREATE INDEX idx_trades_log_exec_at           ON trades_log (executed_at DESC);
CREATE INDEX idx_candles_symbol_interval_time ON candles    (symbol, interval, open_time DESC);

-- ──────────────────────────────────────────────────────────────────────────────
-- SEED DATA
-- 4 mock users (IDs 1-4), 2 assets, generous initial balances.
-- ──────────────────────────────────────────────────────────────────────────────

INSERT INTO users (id, username) VALUES
    (1, 'alice'),
    (2, 'bob'),
    (3, 'charlie'),
    (4, 'dave')
ON CONFLICT (id) DO NOTHING;

INSERT INTO assets (symbol, name, decimals) VALUES
    ('BTC',  'Bitcoin',    8),
    ('USDT', 'Tether USD', 2)
ON CONFLICT (symbol) DO NOTHING;

INSERT INTO balances (user_id, asset_symbol, available, locked) VALUES
    (1, 'BTC',  100.00000000, 0),
    (1, 'USDT', 10000000.00000000, 0),
    (2, 'BTC',  100.00000000, 0),
    (2, 'USDT', 10000000.00000000, 0),
    (3, 'BTC',  100.00000000, 0),
    (3, 'USDT', 10000000.00000000, 0),
    (4, 'BTC',  100.00000000, 0),
    (4, 'USDT', 10000000.00000000, 0)
ON CONFLICT (user_id, asset_symbol) DO NOTHING;
