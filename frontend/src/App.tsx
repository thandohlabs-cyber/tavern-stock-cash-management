const summaryCards = [
  { label: 'Today Cash Position', value: 'R 48,250.00', tone: 'positive' },
  { label: 'Today Card Sales', value: 'R 24,860.00', tone: 'neutral' },
  { label: 'Safe Balance', value: 'R 12,110.00', tone: 'neutral' },
  { label: 'Pending Card Settlements', value: 'R 8,940.00', tone: 'warning' },
];

const statuses = [
  'Open',
  'Balancing',
  'Balanced',
  'Closed',
  'Pending',
  'Confirmed',
  'Unreconciled',
];

const quickActions = [
  'Open POS Day',
  'Receive Stock',
  'Record Expense',
  'Stock Balance',
  'Bank Cash',
  'Run Reconciliation',
];

export default function App() {
  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="brand-block">
          <div className="brand-mark">TS</div>
          <div>
            <p className="eyebrow">Tavern System</p>
            <h1>Tavern Stock</h1>
          </div>
        </div>

        <nav className="nav">
          <span className="nav-title">Dashboard</span>
          <span>Cash</span>
          <span>Stock</span>
          <span>Reports</span>
          <span>Settings</span>
        </nav>
      </aside>

      <main className="content">
        <header className="topbar">
          <div>
            <p className="eyebrow">Overview</p>
            <h2>Operations Dashboard</h2>
          </div>
          <button className="primary-button">New Stock Period</button>
        </header>

        <section className="summary-grid">
          {summaryCards.map((card) => (
            <article key={card.label} className={`summary-card ${card.tone}`}>
              <span>{card.label}</span>
              <strong>{card.value}</strong>
            </article>
          ))}
        </section>

        <section className="panel-grid">
          <article className="panel">
            <div className="panel-header">
              <h3>POS Terminal Status</h3>
              <span className="chip success">Open</span>
            </div>
            <ul className="list">
              <li>
                <span>POS 01</span>
                <strong>Open</strong>
              </li>
              <li>
                <span>POS 02</span>
                <strong>Balancing</strong>
              </li>
              <li>
                <span>POS 03</span>
                <strong>Pending</strong>
              </li>
            </ul>
          </article>

          <article className="panel">
            <div className="panel-header">
              <h3>Stock Alerts</h3>
              <span className="chip warning">Low Stock</span>
            </div>
            <ul className="list">
              <li>
                <span>Castle Lite 24s</span>
                <strong>6 cases left</strong>
              </li>
              <li>
                <span>Whiskey 12s</span>
                <strong>2 cases left</strong>
              </li>
            </ul>
          </article>

          <article className="panel wide">
            <div className="panel-header">
              <h3>Latest Stock Period</h3>
              <span className="chip neutral">Balanced</span>
            </div>
            <div className="kpi-row">
              <div>
                <small>Period</small>
                <strong>Week 41</strong>
              </div>
              <div>
                <small>Stock Sold Value</small>
                <strong>R 192,450.00</strong>
              </div>
              <div>
                <small>Reconciliation</small>
                <strong>R 3,120.00</strong>
              </div>
            </div>
          </article>
        </section>

        <section className="panel">
          <div className="panel-header">
            <h3>System Status Labels</h3>
          </div>
          <div className="status-row">
            {statuses.map((status) => (
              <span key={status} className="chip neutral">
                {status}
              </span>
            ))}
          </div>
        </section>

        <section className="panel">
          <div className="panel-header">
            <h3>Quick Actions</h3>
          </div>
          <div className="quick-actions">
            {quickActions.map((action) => (
              <button key={action} className="secondary-button">
                {action}
              </button>
            ))}
          </div>
        </section>
      </main>
    </div>
  );
}
