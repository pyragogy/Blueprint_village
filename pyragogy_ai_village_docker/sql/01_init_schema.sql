-- Pyragogy AI Village - Schema di inizializzazione
-- Questo script crea le tabelle necessarie per il funzionamento del Pyragogy AI Village

-- Estensione per supporto vettoriale (per embedding)
CREATE EXTENSION IF NOT EXISTS vector;

-- Tabella principale per i contenuti del handbook
CREATE TABLE IF NOT EXISTS handbook_entries (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  version INT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_by TEXT,
  tags TEXT[],
  embedding VECTOR(1536)
);

-- Tabella per tracciare i contributi degli agenti
CREATE TABLE IF NOT EXISTS agent_contributions (
  id SERIAL PRIMARY KEY,
  entry_id INT REFERENCES handbook_entries(id),
  agent_name TEXT NOT NULL,
  contribution_type TEXT NOT NULL,
  timestamp TIMESTAMP DEFAULT NOW(),
  details JSONB
);

-- Tabella per la cronologia delle versioni
CREATE TABLE IF NOT EXISTS handbook_history (
  id SERIAL PRIMARY KEY,
  entry_id INT REFERENCES handbook_entries(id),
  content TEXT NOT NULL,
  version INT NOT NULL,
  changed_at TIMESTAMP DEFAULT NOW(),
  changed_by TEXT,
  change_description TEXT
);

-- Tabella per metriche del ritmo cognitivo
CREATE TABLE IF NOT EXISTS cognitive_rhythm_metrics (
  id SERIAL PRIMARY KEY,
  session_id TEXT NOT NULL,
  timestamp TIMESTAMP DEFAULT NOW(),
  human_phase_shift FLOAT,
  human_confidence FLOAT,
  ai_phase_shift FLOAT,
  ai_confidence FLOAT,
  synchronization_index FLOAT,
  sync_confidence FLOAT,
  resonance FLOAT,
  resonance_confidence FLOAT,
  cognitive_rhythm FLOAT,
  rhythm_confidence FLOAT
);

-- Indici per migliorare le performance
CREATE INDEX IF NOT EXISTS idx_handbook_entries_title ON handbook_entries(title);
CREATE INDEX IF NOT EXISTS idx_handbook_entries_created_at ON handbook_entries(created_at);
CREATE INDEX IF NOT EXISTS idx_agent_contributions_entry_id ON agent_contributions(entry_id);
CREATE INDEX IF NOT EXISTS idx_agent_contributions_agent_name ON agent_contributions(agent_name);
CREATE INDEX IF NOT EXISTS idx_cognitive_rhythm_metrics_session_id ON cognitive_rhythm_metrics(session_id);
CREATE INDEX IF NOT EXISTS idx_cognitive_rhythm_metrics_timestamp ON cognitive_rhythm_metrics(timestamp);

-- Funzione per aggiornare il timestamp di updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger per aggiornare automaticamente updated_at
CREATE TRIGGER update_handbook_entries_updated_at
BEFORE UPDATE ON handbook_entries
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Funzione per aggiornare la cronologia delle versioni
CREATE OR REPLACE FUNCTION update_handbook_history()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO handbook_history(entry_id, content, version, changed_by, change_description)
    VALUES(OLD.id, OLD.content, OLD.version, NEW.created_by, 'Content update');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger per aggiornare automaticamente la cronologia
CREATE TRIGGER handbook_history_trigger
AFTER UPDATE ON handbook_entries
FOR EACH ROW
WHEN (OLD.content IS DISTINCT FROM NEW.content)
EXECUTE FUNCTION update_handbook_history();

-- Commento finale
COMMENT ON TABLE handbook_entries IS 'Tabella principale per i contenuti del Pyragogy Handbook';
COMMENT ON TABLE agent_contributions IS 'Traccia i contributi degli agenti AI';
COMMENT ON TABLE handbook_history IS 'Cronologia delle versioni dei contenuti';
COMMENT ON TABLE cognitive_rhythm_metrics IS 'Metriche per il monitoraggio del ritmo cognitivo';
