# Pyragogy AI Village - Stack Docker

Questo repository contiene uno stack Docker completo per implementare il Pyragogy AI Village, un ecosistema sperimentale per l'apprendimento collaborativo uomo-AI basato sui principi del Manifesto Pyragogy e della Teoria del Ritmo Cognitivo.

## Indice

- [Panoramica](#panoramica)
- [Requisiti](#requisiti)
- [Struttura del Progetto](#struttura-del-progetto)
- [Avvio Rapido](#avvio-rapido)
- [Configurazione](#configurazione)
- [Utilizzo](#utilizzo)
- [Test End-to-End](#test-end-to-end)
- [Estensione del Sistema](#estensione-del-sistema)
- [Monitoraggio e Dashboard](#monitoraggio-e-dashboard)
- [Backup e Ripristino](#backup-e-ripristino)
- [Risoluzione Problemi](#risoluzione-problemi)
- [Licenza](#licenza)

## Panoramica

Pyragogy AI Village è un sistema multi-agente orchestrato che permette la collaborazione tra agenti AI specializzati e utenti umani per la co-creazione di contenuti. Il sistema utilizza:

- **n8n** per l'orchestrazione dei workflow e l'automazione
- **PostgreSQL** per la persistenza dei dati
- **Grafana** per il monitoraggio e la visualizzazione del ritmo cognitivo
- **Nginx** per servire contenuti statici e come reverse proxy

Gli agenti implementati includono:
- Meta-orchestrator
- Summarizer
- Synthesizer
- Peer Reviewer
- Sensemaking Agent
- Prompt Engineer
- Onboarding/Explainer
- Archivist

## Requisiti

- Docker e Docker Compose (v2.0+)
- 4GB RAM e 2 vCPU (minimo)
- Connessione internet (per le API OpenAI)
- API key OpenAI (per GPT-4o o modelli simili)
- (Opzionale) Token di accesso GitHub per il versioning

## Struttura del Progetto

```
pyragogy_ai_village_docker/
├── docker-compose.yml        # Configurazione dello stack Docker
├── .env.example              # Template per le variabili d'ambiente
├── sql/                      # Script SQL per l'inizializzazione del database
│   └── 01_init_schema.sql    # Schema iniziale del database
├── workflows/                # Workflow n8n
│   └── pyragogy_master_workflow.json  # Workflow master per l'orchestrazione
├── grafana/                  # Configurazione Grafana
│   ├── provisioning/         # Provisioning automatico
│   │   └── datasources/      # Configurazione datasource
│   └── dashboards/           # Dashboard predefinite
├── nginx/                    # Configurazione Nginx
│   ├── conf.d/               # File di configurazione
│   └── html/                 # Contenuti statici
└── docs/                     # Documentazione aggiuntiva
    └── extending_workflow.md # Guida all'estensione del workflow
```

## Avvio Rapido

1. Clona questo repository:
   ```bash
   git clone https://github.com/yourusername/pyragogy-ai-village.git
   cd pyragogy-ai-village
   ```

2. Crea il file `.env` a partire dal template:
   ```bash
   cp .env.example .env
   ```

3. Modifica il file `.env` inserendo le tue credenziali:
   ```bash
   nano .env
   ```

4. Avvia lo stack Docker:
   ```bash
   docker-compose up -d
   ```

5. Accedi all'interfaccia web:
   - n8n: http://localhost:5678
   - Grafana: http://localhost:3000
   - Homepage: http://localhost

## Configurazione

### Variabili d'Ambiente

Le principali variabili da configurare nel file `.env` sono:

- `OPENAI_API_KEY`: La tua API key di OpenAI
- `POSTGRES_PASSWORD`: Password per il database PostgreSQL
- `GITHUB_ACCESS_TOKEN`: (Opzionale) Token di accesso GitHub per il versioning
- `SLACK_WEBHOOK_URL`: (Opzionale) URL webhook per le notifiche Slack

### Credenziali n8n

Dopo il primo avvio, è necessario configurare le credenziali in n8n:

1. Accedi a n8n (http://localhost:5678)
2. Vai su "Settings" > "Credentials"
3. Aggiungi le seguenti credenziali:
   - **OpenAI**: Inserisci la tua API key
   - **PostgreSQL**: Usa i parametri dal file `.env`
   - **GitHub**: (Opzionale) Inserisci il tuo token di accesso

### Importazione del Workflow

1. In n8n, vai su "Workflows"
2. Clicca su "Import from File"
3. Seleziona il file `workflows/pyragogy_master_workflow.json`
4. Salva il workflow importato
5. Attiva il workflow cliccando su "Activate"

## Utilizzo

### Invio di Richieste al Sistema

Puoi interagire con il sistema inviando richieste HTTP POST all'endpoint del webhook:

```bash
curl -X POST http://localhost:5678/webhook/pyragogy/process \
  -H "Content-Type: application/json" \
  -d '{
    "input": "Questo è un testo di esempio da elaborare",
    "title": "Esempio di Elaborazione",
    "tags": ["test", "esempio"],
    "version": 1,
    "author": "Utente Test"
  }'
```

### Parametri della Richiesta

- `input`: Il testo da elaborare (obbligatorio)
- `title`: Titolo del contenuto (opzionale)
- `tags`: Array di tag per la categorizzazione (opzionale)
- `version`: Numero di versione (opzionale, default: 1)
- `author`: Autore del contenuto (opzionale)

### Risposta del Sistema

Il sistema risponderà con un JSON contenente:

- `finalOutput`: L'output finale dell'ultimo agente eseguito
- `contributions`: Array con i contributi di ciascun agente
- `agentSequence`: Sequenza degli agenti eseguiti

## Test End-to-End

Per verificare il corretto funzionamento dell'intero sistema:

1. Assicurati che tutti i container siano in esecuzione:
   ```bash
   docker-compose ps
   ```

2. Invia una richiesta di test:
   ```bash
   curl -X POST http://localhost:5678/webhook/pyragogy/process \
     -H "Content-Type: application/json" \
     -d '{
       "input": "La Teoria del Ritmo Cognitivo esplora la sincronizzazione tra stati cognitivi umani e AI durante la collaborazione. Questa teoria è fondamentale per comprendere come ottimizzare l'interazione uomo-macchina in contesti di co-creazione.",
       "title": "Test Ritmo Cognitivo",
       "tags": ["teoria", "ritmo-cognitivo", "test"],
       "version": 1
     }'
   ```

3. Verifica i risultati:
   - Controlla la risposta JSON
   - Verifica i dati nel database PostgreSQL
   - Controlla le notifiche (se configurate)
   - Verifica il commit su GitHub (se abilitato)

4. Controlla i log per eventuali errori:
   ```bash
   docker-compose logs n8n
   ```

## Estensione del Sistema

### Aggiunta di Nuovi Agenti

Per aggiungere nuovi agenti al sistema, consulta la guida dettagliata in `docs/extending_workflow.md`.

In sintesi:
1. Aggiungi un nuovo nodo condizionale nel workflow
2. Crea il nodo dell'agente con il prompt appropriato
3. Aggiorna il nodo "Process Agent Output"
4. Aggiorna il prompt del Meta-orchestrator
5. Collega i nodi nel workflow

### Personalizzazione dei Prompt

I prompt degli agenti possono essere personalizzati modificando il workflow in n8n:

1. Accedi al workflow in n8n
2. Seleziona il nodo dell'agente da modificare
3. Modifica il messaggio di sistema nel campo "Content"
4. Salva le modifiche

### Integrazione con Altri Servizi

Per integrare il sistema con altri servizi:

1. Aggiungi le credenziali necessarie in n8n
2. Crea un nuovo workflow o modifica quello esistente
3. Aggiungi i nodi per l'integrazione (HTTP Request, API specifiche, ecc.)
4. Collega i nodi al flusso principale

## Monitoraggio e Dashboard

### Accesso a Grafana

1. Accedi a Grafana (http://localhost:3000)
2. Usa le credenziali predefinite:
   - Username: admin
   - Password: pyragogy_grafana_password (o quella specificata nel file docker-compose.yml)

### Dashboard Disponibili

- **Cognitive Rhythm Dashboard**: Visualizza metriche del ritmo cognitivo
- **Agent Performance**: Monitora le performance degli agenti
- **System Overview**: Panoramica dello stato del sistema

### Creazione di Nuove Dashboard

1. In Grafana, clicca su "Create" > "Dashboard"
2. Aggiungi nuovi pannelli con le metriche desiderate
3. Configura le query PostgreSQL per estrarre i dati
4. Salva la dashboard

## Backup e Ripristino

### Backup dei Dati

Per eseguire un backup del database e delle configurazioni:

```bash
# Backup del database PostgreSQL
docker exec pyragogy-postgres pg_dump -U pyragogy pyragogy > backup_$(date +%Y%m%d).sql

# Backup dei volumi Docker
docker run --rm -v pyragogy-postgres-data:/source -v $(pwd)/backups:/backup alpine tar -czf /backup/postgres_data_$(date +%Y%m%d).tar.gz /source
docker run --rm -v pyragogy-n8n-data:/source -v $(pwd)/backups:/backup alpine tar -czf /backup/n8n_data_$(date +%Y%m%d).tar.gz /source
```

### Ripristino dei Dati

Per ripristinare da un backup:

```bash
# Ripristino del database PostgreSQL
cat backup_YYYYMMDD.sql | docker exec -i pyragogy-postgres psql -U pyragogy pyragogy

# Ripristino dei volumi Docker (richiede stop dei container)
docker-compose down
docker run --rm -v pyragogy-postgres-data:/target -v $(pwd)/backups:/backup alpine sh -c "rm -rf /target/* && tar -xzf /backup/postgres_data_YYYYMMDD.tar.gz -C /target --strip-components=1"
docker-compose up -d
```

## Risoluzione Problemi

### Problemi Comuni

#### n8n non si connette al database

Verifica:
- Le credenziali PostgreSQL nel file `.env`
- Lo stato del container PostgreSQL: `docker-compose logs postgres`
- La rete Docker: `docker network inspect pyragogy-network`

#### Errori nelle chiamate API OpenAI

Verifica:
- La validità della tua API key OpenAI
- La connessione internet del container n8n
- I limiti di rate della tua API key

#### Workflow non attivo

Verifica:
- Lo stato del workflow in n8n
- I log di n8n: `docker-compose logs n8n`
- Le credenziali configurate in n8n

### Restart dei Servizi

Per riavviare un servizio specifico:

```bash
docker-compose restart [service_name]
```

Per riavviare l'intero stack:

```bash
docker-compose down
docker-compose up -d
```

## Licenza

Questo progetto è rilasciato sotto licenza MIT. Vedi il file LICENSE per i dettagli.

---

Creato per il Pyragogy AI Village - Un ecosistema sperimentale per l'apprendimento collaborativo uomo-AI basato sui principi del Manifesto Pyragogy e della Teoria del Ritmo Cognitivo.
