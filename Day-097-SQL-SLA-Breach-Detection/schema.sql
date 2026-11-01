-- Day 97: SupportPulse — schema
-- PostgreSQL 14+

DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS agents;

CREATE TABLE agents (
    agent_id       INTEGER PRIMARY KEY,
    agent_name     VARCHAR(80) NOT NULL,
    team_name      VARCHAR(40) NOT NULL,
    hire_date      DATE NOT NULL
);

CREATE TABLE customers (
    customer_id    INTEGER PRIMARY KEY,
    company_name   VARCHAR(100) NOT NULL,
    plan           VARCHAR(20) NOT NULL
                   CHECK (plan IN ('Free', 'Starter', 'Pro', 'Enterprise')),
    country        CHAR(2) NOT NULL
);

CREATE TABLE tickets (
    ticket_id          INTEGER PRIMARY KEY,
    customer_id        INTEGER NOT NULL REFERENCES customers(customer_id),
    agent_id           INTEGER REFERENCES agents(agent_id),
    subject            VARCHAR(160) NOT NULL,
    priority           VARCHAR(10) NOT NULL
                       CHECK (priority IN ('Critical', 'High', 'Medium', 'Low')),
    status             VARCHAR(15) NOT NULL
                       CHECK (status IN ('Open', 'In Progress', 'Resolved')),
    created_at         TIMESTAMPTZ NOT NULL,
    first_response_at  TIMESTAMPTZ,
    resolved_at        TIMESTAMPTZ,
    CHECK (first_response_at IS NULL OR first_response_at >= created_at),
    CHECK (resolved_at IS NULL OR resolved_at >= created_at),
    CHECK (resolved_at IS NULL OR status = 'Resolved')
);

CREATE INDEX idx_tickets_created_at ON tickets(created_at);
CREATE INDEX idx_tickets_priority_status ON tickets(priority, status);
CREATE INDEX idx_tickets_agent_created ON tickets(agent_id, created_at);
