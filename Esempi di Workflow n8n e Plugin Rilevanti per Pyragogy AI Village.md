# Esempi di Workflow n8n e Plugin Rilevanti per Pyragogy AI Village

Questo documento raccoglie esempi pratici di workflow n8n e plugin rilevanti per l'implementazione del sistema multi-agente del Pyragogy AI Village. Gli esempi sono stati selezionati e adattati per rispondere alle esigenze specifiche del progetto, con particolare attenzione all'orchestrazione degli agenti, all'integrazione con LLM e alla gestione del ritmo cognitivo.

## Indice
1. [Plugin Essenziali per n8n](#plugin-essenziali-per-n8n)
2. [Workflow di Base: Orchestrazione Multi-Agente](#workflow-di-base-orchestrazione-multi-agente)
3. [Workflow Avanzato: Ritmo Cognitivo e Feedback Loop](#workflow-avanzato-ritmo-cognitivo-e-feedback-loop)
4. [Workflow per Persistenza e Versioning](#workflow-per-persistenza-e-versioning)
5. [Workflow per Visualizzazione e Dashboard](#workflow-per-visualizzazione-e-dashboard)
6. [Risorse e Riferimenti](#risorse-e-riferimenti)

## Plugin Essenziali per n8n

### Plugin per Integrazione LLM

| Nome Plugin | Descrizione | Installazione | Utilizzo nel Pyragogy AI Village |
|-------------|-------------|--------------|----------------------------------|
| **n8n-nodes-openai** | Integrazione con OpenAI API (GPT-4o) | `npm install n8n-nodes-openai` | Agenti principali: Summarizer, Synthesizer, Meta-orchestrator |
| **n8n-nodes-langchain** | Integrazione con LangChain per workflow LLM avanzati | `npm install n8n-nodes-langchain` | Pattern complessi, RAG, agent con memoria |
| **n8n-nodes-huggingface** | Integrazione con HuggingFace per modelli open source | `npm install n8n-nodes-huggingface` | Agenti secondari, modelli specializzati |
| **n8n-nodes-anthropic** | Integrazione con Claude di Anthropic | `npm install n8n-nodes-anthropic` | Alternativa per agenti che richiedono ragionamento complesso |

### Plugin per Persistenza e Database

| Nome Plugin | Descrizione | Installazione | Utilizzo nel Pyragogy AI Village |
|-------------|-------------|--------------|----------------------------------|
| **n8n-nodes-supabase** | Integrazione con Supabase per database e storage | `npm install n8n-nodes-supabase` | Persistenza strutturata, query semantiche |
| **n8n-nodes-postgres** | Connessione diretta a PostgreSQL | `npm install n8n-nodes-postgres` | Database principale per contenuti e metadati |
| **n8n-nodes-github** | Integrazione con GitHub per versioning | `npm install n8n-nodes-github` | Versioning del Pyragogy Handbook |
| **n8n-nodes-elastic** | Integrazione con Elasticsearch | `npm install n8n-nodes-elastic` | Ricerca semantica avanzata (opzionale) |

### Plugin per Visualizzazione e Monitoraggio

| Nome Plugin | Descrizione | Installazione | Utilizzo nel Pyragogy AI Village |
|-------------|-------------|--------------|----------------------------------|
| **n8n-nodes-grafana** | Integrazione con Grafana per dashboard | `npm install n8n-nodes-grafana` | Visualizzazione del ritmo cognitivo |
| **n8n-nodes-mermaid** | Generazione di diagrammi con Mermaid | `npm install n8n-nodes-mermaid` | Visualizzazione di workflow e relazioni |
| **n8n-nodes-prometheus** | Monitoraggio con Prometheus | `npm install n8n-nodes-prometheus` | Metriche di performance del sistema |

## Workflow di Base: Orchestrazione Multi-Agente

### Esempio 1: Meta-orchestrator con Distribuzione Task

```json
{
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "orchestrate",
        "options": {}
      },
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [
        250,
        300
      ]
    },
    {
      "parameters": {
        "authentication": "apiKey",
        "resource": "chat",
        "prompt": {
          "messages": [
            {
              "role": "system",
              "content": "Sei il Meta-orchestrator del Pyragogy AI Village. Il tuo compito è analizzare l'input ricevuto e decidere quali agenti attivare e in quale ordine. Restituisci un JSON con la sequenza di agenti da attivare e i parametri per ciascuno."
            },
            {
              "role": "user",
              "content": "={{$json.body.input}}"
            }
          ]
        },
        "options": {
          "model": "gpt-4o"
        }
      },
      "name": "OpenAI",
      "type": "n8n-nodes-base.openAi",
      "typeVersion": 1,
      "position": [
        450,
        300
      ]
    },
    {
      "parameters": {
        "functionCode": "// Analizza la risposta del Meta-orchestrator\nconst response = JSON.parse(items[0].json.response.choices[0].message.content);\n\n// Prepara la distribuzione dei task\nconst agents = response.agents;\nconst tasks = [];\n\n// Crea un task per ogni agente\nfor (const agent of agents) {\n  tasks.push({\n    agentName: agent.name,\n    agentRole: agent.role,\n    parameters: agent.parameters,\n    input: items[0].json.body.input,\n    priority: agent.priority || 1\n  });\n}\n\n// Ordina i task per priorità\ntasks.sort((a, b) => a.priority - b.priority);\n\nreturn {json: {tasks}};"
      },
      "name": "Prepare Tasks",
      "type": "n8n-nodes-base.function",
      "typeVersion": 1,
      "position": [
        650,
        300
      ]
    },
    {
      "parameters": {
        "batchSize": 1,
        "options": {}
      },
      "name": "Split In Batches",
      "type": "n8n-nodes-base.splitInBatches",
      "typeVersion": 1,
      "position": [
        850,
        300
      ]
    },
    {
      "parameters": {
        "conditions": {
          "string": [
            {
              "value1": "={{$json.agentName}}",
              "operation": "equal",
              "value2": "summarizer"
            }
          ]
        }
      },
      "name": "Route to Agent",
      "type": "n8n-nodes-base.if",
      "typeVersion": 1,
      "position": [
        1050,
        300
      ]
    },
    {
      "parameters": {
        "url": "={{$node[\"Set Workflow Variables\"].json.apiBaseUrl}}/agents/summarizer",
        "options": {
          "body": "={{$json}}",
          "headerParametersUi": {
            "parameter": [
              {
                "name": "Content-Type",
                "value": "application/json"
              }
            ]
          }
        }
      },
      "name": "Call Summarizer",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [
        1250,
        200
      ]
    },
    {
      "parameters": {
        "conditions": {
          "string": [
            {
              "value1": "={{$json.agentName}}",
              "operation": "equal",
              "value2": "synthesizer"
            }
          ]
        }
      },
      "name": "Route to Next Agent",
      "type": "n8n-nodes-base.if",
      "typeVersion": 1,
      "position": [
        1050,
        450
      ]
    },
    {
      "parameters": {
        "url": "={{$node[\"Set Workflow Variables\"].json.apiBaseUrl}}/agents/synthesizer",
        "options": {
          "body": "={{$json}}",
          "headerParametersUi": {
            "parameter": [
              {
                "name": "Content-Type",
                "value": "application/json"
              }
            ]
          }
        }
      },
      "name": "Call Synthesizer",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [
        1250,
        450
      ]
    },
    {
      "parameters": {
        "variablesValues": {
          "apiBaseUrl": "http://localhost:3000"
        }
      },
      "name": "Set Workflow Variables",
      "type": "n8n-nodes-base.set",
      "typeVersion": 1,
      "position": [
        250,
        150
      ]
    }
  ],
  "connections": {
    "Webhook": {
      "main": [
        [
          {
            "node": "OpenAI",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "OpenAI": {
      "main": [
        [
          {
            "node": "Prepare Tasks",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Prepare Tasks": {
      "main": [
        [
          {
            "node": "Split In Batches",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Split In Batches": {
      "main": [
        [
          {
            "node": "Route to Agent",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Route to Agent": {
      "main": [
        [
          {
            "node": "Call Summarizer",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Route to Next Agent",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Route to Next Agent": {
      "main": [
        [
          {
            "node": "Call Synthesizer",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  }
}
```

### Esempio 2: Implementazione del Sensemaking Agent

```json
{
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "agents/sensemaking",
        "options": {}
      },
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [
        250,
        300
      ]
    },
    {
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT content, metadata FROM handbook_entries WHERE project_id = {{$json.body.projectId}} ORDER BY created_at DESC LIMIT 10;"
      },
      "name": "Get Recent Entries",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 1,
      "position": [
        450,
        300
      ]
    },
    {
      "parameters": {
        "authentication": "apiKey",
        "resource": "chat",
        "prompt": {
          "messages": [
            {
              "role": "system",
              "content": "Sei il Sensemaking Agent del Pyragogy AI Village. Il tuo compito è analizzare contenuti, trovare connessioni, identificare pattern emergenti e gap cognitivi. Fornisci insight che collegano concetti apparentemente separati e suggerisci direzioni di esplorazione."
            },
            {
              "role": "user",
              "content": "Analizza i seguenti contenuti e identifica pattern, connessioni e gap cognitivi:\n\nInput corrente: {{$json.body.input}}\n\nContenuti recenti: {{$node[\"Get Recent Entries\"].json}}"
            }
          ]
        },
        "options": {
          "model": "gpt-4o"
        }
      },
      "name": "OpenAI",
      "type": "n8n-nodes-base.openAi",
      "typeVersion": 1,
      "position": [
        650,
        300
      ]
    },
    {
      "parameters": {
        "functionCode": "// Estrai l'analisi del Sensemaking Agent\nconst analysis = items[0].json.response.choices[0].message.content;\n\n// Struttura l'output\nreturn {\n  json: {\n    analysis,\n    patterns: extractPatterns(analysis),\n    gaps: extractGaps(analysis),\n    connections: extractConnections(analysis),\n    timestamp: new Date().toISOString()\n  }\n};\n\n// Funzioni helper per estrarre informazioni strutturate\nfunction extractPatterns(text) {\n  // Implementazione semplificata\n  const patternRegex = /pattern|schema|ricorrenza|tendenza/gi;\n  return text.match(patternRegex) ? true : false;\n}\n\nfunction extractGaps(text) {\n  // Implementazione semplificata\n  const gapRegex = /gap|lacuna|mancanza|assenza/gi;\n  return text.match(gapRegex) ? true : false;\n}\n\nfunction extractConnections(text) {\n  // Implementazione semplificata\n  const connectionRegex = /connessione|collegamento|relazione|legame/gi;\n  return text.match(connectionRegex) ? true : false;\n}"
      },
      "name": "Structure Output",
      "type": "n8n-nodes-base.function",
      "typeVersion": 1,
      "position": [
        850,
        300
      ]
    },
    {
      "parameters": {
        "operation": "insert",
        "table": "sensemaking_insights",
        "columns": "analysis, patterns, gaps, connections, timestamp, project_id",
        "values": "={{$json.analysis}}, {{$json.patterns}}, {{$json.gaps}}, {{$json.connections}}, {{$json.timestamp}}, {{$json.body.projectId}}"
      },
      "name": "Save Insights",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 1,
      "position": [
        1050,
        300
      ]
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{$json}}",
        "options": {}
      },
      "name": "Respond to Webhook",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        1250,
        300
      ]
    }
  ],
  "connections": {
    "Webhook": {
      "main": [
        [
          {
            "node": "Get Recent Entries",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Get Recent Entries": {
      "main": [
        [
          {
            "node": "OpenAI",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "OpenAI": {
      "main": [
        [
          {
            "node": "Structure Output",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Structure Output": {
      "main": [
        [
          {
            "node": "Save Insights",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Save Insights": {
      "main": [
        [
          {
            "node": "Respond to Webhook",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  }
}
```

## Workflow Avanzato: Ritmo Cognitivo e Feedback Loop

### Esempio 3: Implementazione del Loop di Feedback con Ritmo Cognitivo

```json
{
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "cognitive-rhythm/feedback",
        "options": {}
      },
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [
        250,
        300
      ]
    },
    {
      "parameters": {
        "operation": "select",
        "table": "cognitive_rhythm_metrics",
        "query": "SELECT * FROM cognitive_rhythm_metrics WHERE session_id = '{{$json.body.sessionId}}' ORDER BY timestamp DESC LIMIT 5;"
      },
      "name": "Get Recent Metrics",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 1,
      "position": [
        450,
        300
      ]
    },
    {
      "parameters": {
        "functionCode": "// Calcola il delta di fase cognitiva umana\nconst humanFeedback = items[0].json.body.feedback;\nconst lastInteractionTime = new Date(items[0].json.body.lastInteractionTime).getTime();\nconst currentTime = new Date().getTime();\n\n// Tempo di risposta in secondi\nconst responseTime = (currentTime - lastInteractionTime) / 1000;\n\n// Analisi semplificata della complessità del feedback\nconst feedbackComplexity = humanFeedback.length / 100;\n\n// Calcolo del delta di fase\nconst humanPhaseShift = {\n  value: responseTime * feedbackComplexity / 10, // Normalizzato\n  confidence: 0.7\n};\n\n// Recupera metriche recenti\nconst recentMetrics = $node[\"Get Recent Metrics\"].json;\n\n// Calcola il delta di fase cognitiva AI (semplificato)\nlet aiPhaseShift = {\n  value: 0.5, // Valore di default\n  confidence: 0.6\n};\n\nif (recentMetrics && recentMetrics.length > 0) {\n  // Usa l'ultimo valore registrato\n  aiPhaseShift = {\n    value: recentMetrics[0].ai_phase_shift,\n    confidence: recentMetrics[0].ai_confidence\n  };\n}\n\n// Calcola l'indice di sincronizzazione\nconst phaseDifference = Math.abs(humanPhaseShift.value - aiPhaseShift.value);\nconst synchronizationIndex = {\n  value: Math.exp(-phaseDifference),\n  confidence: (humanPhaseShift.confidence + aiPhaseShift.confidence) / 2\n};\n\n// Calcola la risonanza (semplificata)\nlet resonance = {\n  value: 0.5, // Valore di default\n  confidence: 0.5\n};\n\nif (recentMetrics && recentMetrics.length >= 3) {\n  // Calcola la stabilità della sincronizzazione\n  const syncValues = recentMetrics.map(m => m.synchronization_index);\n  const syncMean = syncValues.reduce((a, b) => a + b, 0) / syncValues.length;\n  const syncVariance = syncValues.map(v => Math.pow(v - syncMean, 2)).reduce((a, b) => a + b, 0) / syncValues.length;\n  const syncStability = Math.sqrt(syncVariance);\n  \n  resonance = {\n    value: 1 / (1 + syncStability),\n    confidence: 0.6\n  };\n}\n\n// Calcola il ritmo cognitivo complessivo\nconst cognitiveRhythm = {\n  value: (synchronizationIndex.value * 0.7) + (resonance.value * 0.3),\n  confidence: (synchronizationIndex.confidence * 0.7) + (resonance.confidence * 0.3)\n};\n\nreturn {\n  json: {\n    sessionId: items[0].json.body.sessionId,\n    timestamp: new Date().toISOString(),\n    humanPhaseShift: humanPhaseShift.value,\n    humanConfidence: humanPhaseShift.confidence,\n    aiPhaseShift: aiPhaseShift.value,\n    aiConfidence: aiPhaseShift.confidence,\n    synchronizationIndex: synchronizationIndex.value,\n    synchronizationConfidence: synchronizationIndex.confidence,\n    resonance: resonance.value,\n    resonanceConfidence: resonance.confidence,\n    cognitiveRhythm: cognitiveRhythm.value,\n    rhythmConfidence: cognitiveRhythm.confidence\n  }\n};"
      },
      "name": "Calculate Cognitive Rhythm",
      "type": "n8n-nodes-base.function",
      "typeVersion": 1,
      "position": [
        650,
        300
      ]
    },
    {
      "parameters": {
        "operation": "insert",
        "table": "cognitive_rhythm_metrics",
        "columns": "session_id, timestamp, human_phase_shift, human_confidence, ai_phase_shift, ai_confidence, synchronization_index, sync_confidence, resonance, resonance_confidence, cognitive_rhythm, rhythm_confidence",
        "values": "={{$json.sessionId}}, {{$json.timestamp}}, {{$json.humanPhaseShift}}, {{$json.humanConfidence}}, {{$json.aiPhaseShift}}, {{$json.aiConfidence}}, {{$json.synchronizationIndex}}, {{$json.synchronizationConfidence}}, {{$json.resonance}}, {{$json.resonanceConfidence}}, {{$json.cognitiveRhythm}}, {{$json.rhythmConfidence}}"
      },
      "name": "Save Metrics",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 1,
      "position": [
        850,
        300
      ]
    },
    {
      "parameters": {
        "functionCode": "// Determina adattamenti in base al ritmo cognitivo\nconst cognitiveRhythm = items[0].json.cognitiveRhythm;\nconst synchronizationIndex = items[0].json.synchronizationIndex;\n\n// Adattamenti per migliorare la sincronizzazione\nlet adaptations = {\n  responseTime: 'normal',\n  complexityLevel: 'medium',\n  detailLevel: 'balanced',\n  interactionStyle: 'neutral'\n};\n\n// Adatta in base al ritmo cognitivo\nif (cognitiveRhythm < 0.3) {\n  // Basso ritmo cognitivo: semplifica e rallenta\n  adaptations = {\n    responseTime: 'slower',\n    complexityLevel: 'simple',\n    detailLevel: 'essential',\n    interactionStyle: 'supportive'\n  };\n} else if (cognitiveRhythm < 0.6) {\n  // Ritmo cognitivo medio: bilanciato\n  adaptations = {\n    responseTime: 'normal',\n    complexityLevel: 'medium',\n    detailLevel: 'balanced',\n    interactionStyle: 'collaborative'\n  };\n} else {\n  // Alto ritmo cognitivo: più complesso e veloce\n  adaptations = {\n    responseTime: 'faster',\n    complexityLevel: 'complex',\n    detailLevel: 'comprehensive',\n    interactionStyle: 'challenging'\n  };\n}\n\n// Adatta in base alla sincronizzazione\nif (synchronizationIndex < 0.4) {\n  // Bassa sincronizzazione: più supporto\n  adaptations.interactionStyle = 'supportive';\n}\n\nreturn {\n  json: {\n    ...items[0].json,\n    adaptations\n  }\n};"
      },
      "name": "Determine Adaptations",
      "type": "n8n-nodes-base.function",
      "typeVersion": 1,
      "position": [
        1050,
        300
      ]
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{$json}}",
        "options": {}
      },
      "name": "Respond to Webhook",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        1250,
        300
      ]
    }
  ],
  "connections": {
    "Webhook": {
      "main": [
        [
          {
            "node": "Get Recent Metrics",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Get Recent Metrics": {
      "main": [
        [
          {
            "node": "Calculate Cognitive Rhythm",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Calculate Cognitive Rhythm": {
      "main": [
        [
          {
            "node": "Save Metrics",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Save Metrics": {
      "main": [
        [
          {
            "node": "Determine Adaptations",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Determine Adaptations": {
      "main": [
        [
          {
            "node": "Respond to Webhook",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  }
}
```

## Workflow per Persistenza e Versioning

### Esempio 4: Archiviazione e Versioning su GitHub

```json
{
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "archive",
        "options": {}
      },
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [
        250,
        300
      ]
    },
    {
      "parameters": {
        "functionCode": "// Formatta il contenuto in Markdown\nconst content = items[0].json.body.content;\nconst metadata = items[0].json.body.metadata || {};\nconst title = metadata.title || 'Untitled';\nconst authors = metadata.authors || ['System'];\nconst tags = metadata.tags || [];\nconst date = new Date().toISOString().split('T')[0];\n\n// Crea il frontmatter\nconst frontmatter = `---\ntitle: \"${title}\"\ndate: ${date}\nauthors: [${authors.map(a => `\"${a}\"`).join(', ')}]\ntags: [${tags.map(t => `\"${t}\"`).join(', ')}]\nversion: ${metadata.version || 1}\n---\n\n`;\n\n// Combina frontmatter e contenuto\nconst formattedContent = frontmatter + content;\n\n// Genera il nome del file\nconst slug = title.toLowerCase().replace(/[^a-z0-9]+/g, '-');\nconst filename = `${slug}.md`;\nconst filepath = `content/${metadata.section || 'general'}/${filename}`;\n\nreturn {\n  json: {\n    content: formattedContent,\n    filepath,\n    metadata\n  }\n};"
      },
      "name": "Format Content",
      "type": "n8n-nodes-base.function",
      "typeVersion": 1,
      "position": [
        450,
        300
      ]
    },
    {
      "parameters": {
        "operation": "insert",
        "table": "handbook_entries",
        "columns": "title, content, version, created_at, created_by, tags, section",
        "values": "={{$json.metadata.title}}, {{$json.content}}, {{$json.metadata.version || 1}}, NOW(), {{$json.metadata.authors[0] || 'System'}}, ARRAY[{{$json.metadata.tags.map(t => `'${t}'`).join(', ') || ''}}], {{$json.metadata.section || 'general'}}"
      },
      "name": "Save to Database",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 1,
      "position": [
        650,
        200
      ]
    },
    {
      "parameters": {
        "authentication": "oAuth2",
        "resource": "file",
        "owner": "={{$node[\"Set Variables\"].json.githubOwner}}",
        "repository": "={{$node[\"Set Variables\"].json.githubRepo}}",
        "filePath": "={{$json.filepath}}",
        "fileContent": "={{$json.content}}",
        "commitMessage": "Add/Update: {{$json.metadata.title}}"
      },
      "name": "GitHub Create/Update File",
      "type": "n8n-nodes-base.github",
      "typeVersion": 1,
      "position": [
        650,
        400
      ]
    },
    {
      "parameters": {
        "authentication": "oAuth2",
        "resource": "issue",
        "owner": "={{$node[\"Set Variables\"].json.githubOwner}}",
        "repository": "={{$node[\"Set Variables\"].json.githubRepo}}",
        "title": "Review: {{$json.metadata.title}}",
        "body": "Please review the latest addition to the Pyragogy Handbook:\n\n**Title**: {{$json.metadata.title}}\n**Section**: {{$json.metadata.section || 'general'}}\n**Version**: {{$json.metadata.version || 1}}\n**Authors**: {{$json.metadata.authors.join(', ') || 'System'}}\n\nFile path: {{$json.filepath}}\n\nTags: {{$json.metadata.tags.join(', ') || 'none'}}",
        "labels": [
          "review",
          "handbook"
        ]
      },
      "name": "Create GitHub Issue",
      "type": "n8n-nodes-base.github",
      "typeVersion": 1,
      "position": [
        850,
        400
      ]
    },
    {
      "parameters": {
        "variablesValues": {
          "githubOwner": "pyragogy",
          "githubRepo": "handbook"
        }
      },
      "name": "Set Variables",
      "type": "n8n-nodes-base.set",
      "typeVersion": 1,
      "position": [
        250,
        150
      ]
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={\n  \"success\": true,\n  \"message\": \"Content archived successfully\",\n  \"filepath\": \"{{$json.filepath}}\",\n  \"issueUrl\": \"{{$node[\"Create GitHub Issue\"].json.html_url}}\"\n}",
        "options": {}
      },
      "name": "Respond to Webhook",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        1050,
        300
      ]
    }
  ],
  "connections": {
    "Webhook": {
      "main": [
        [
          {
            "node": "Format Content",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Format Content": {
      "main": [
        [
          {
            "node": "Save to Database",
            "type": "main",
            "index": 0
          },
          {
            "node": "GitHub Create/Update File",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "GitHub Create/Update File": {
      "main": [
        [
          {
            "node": "Create GitHub Issue",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Save to Database": {
      "main": [
        [
          {
            "node": "Respond to Webhook",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Create GitHub Issue": {
      "main": [
        [
          {
            "node": "Respond to Webhook",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  }
}
```

## Workflow per Visualizzazione e Dashboard

### Esempio 5: Dashboard per Ritmo Cognitivo

```json
{
  "nodes": [
    {
      "parameters": {
        "rule": {
          "interval": [
            {
              "field": "minutes",
              "minutesInterval": 5
            }
          ]
        }
      },
      "name": "Schedule Trigger",
      "type": "n8n-nodes-base.scheduleTrigger",
      "typeVersion": 1,
      "position": [
        250,
        300
      ]
    },
    {
      "parameters": {
        "operation": "select",
        "table": "cognitive_rhythm_metrics",
        "query": "SELECT session_id, timestamp, cognitive_rhythm, synchronization_index, resonance FROM cognitive_rhythm_metrics WHERE timestamp > NOW() - INTERVAL '24 hours' ORDER BY timestamp;"
      },
      "name": "Get Metrics",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 1,
      "position": [
        450,
        300
      ]
    },
    {
      "parameters": {
        "functionCode": "// Prepara i dati per la visualizzazione\nconst metrics = items[0].json;\n\n// Raggruppa per sessione\nconst sessions = {};\nfor (const metric of metrics) {\n  if (!sessions[metric.session_id]) {\n    sessions[metric.session_id] = [];\n  }\n  sessions[metric.session_id].push({\n    timestamp: new Date(metric.timestamp).getTime(),\n    cognitiveRhythm: metric.cognitive_rhythm,\n    synchronizationIndex: metric.synchronization_index,\n    resonance: metric.resonance\n  });\n}\n\n// Prepara i dati per i grafici\nconst datasets = [];\nconst colors = ['#4285F4', '#EA4335', '#FBBC05', '#34A853', '#8F00FF', '#00FFFF'];\nlet colorIndex = 0;\n\nfor (const sessionId in sessions) {\n  const sessionData = sessions[sessionId];\n  \n  // Ordina per timestamp\n  sessionData.sort((a, b) => a.timestamp - b.timestamp);\n  \n  // Aggiungi dataset per ritmo cognitivo\n  datasets.push({\n    label: `Session ${sessionId} - Cognitive Rhythm`,\n    data: sessionData.map(d => ({ x: d.timestamp, y: d.cognitiveRhythm })),\n    borderColor: colors[colorIndex % colors.length],\n    backgroundColor: `${colors[colorIndex % colors.length]}33`,\n    fill: false\n  });\n  colorIndex++;\n  \n  // Aggiungi dataset per indice di sincronizzazione\n  datasets.push({\n    label: `Session ${sessionId} - Synchronization`,\n    data: sessionData.map(d => ({ x: d.timestamp, y: d.synchronizationIndex })),\n    borderColor: colors[colorIndex % colors.length],\n    backgroundColor: `${colors[colorIndex % colors.length]}33`,\n    fill: false\n  });\n  colorIndex++;\n}\n\n// Configura il grafico\nconst chartConfig = {\n  type: 'line',\n  data: {\n    datasets\n  },\n  options: {\n    responsive: true,\n    title: {\n      display: true,\n      text: 'Cognitive Rhythm Dashboard'\n    },\n    scales: {\n      x: {\n        type: 'time',\n        time: {\n          unit: 'minute'\n        },\n        title: {\n          display: true,\n          text: 'Time'\n        }\n      },\n      y: {\n        min: 0,\n        max: 1,\n        title: {\n          display: true,\n          text: 'Value'\n        }\n      }\n    }\n  }\n};\n\nreturn {\n  json: {\n    chartConfig,\n    sessions: Object.keys(sessions).length,\n    dataPoints: metrics.length\n  }\n};"
      },
      "name": "Prepare Chart Data",
      "type": "n8n-nodes-base.function",
      "typeVersion": 1,
      "position": [
        650,
        300
      ]
    },
    {
      "parameters": {
        "url": "https://quickchart.io/chart",
        "options": {
          "method": "POST",
          "body": "={{ JSON.stringify($json.chartConfig) }}",
          "headerParametersUi": {
            "parameter": [
              {
                "name": "Content-Type",
                "value": "application/json"
              }
            ]
          }
        },
        "responseFormat": "file"
      },
      "name": "Generate Chart",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [
        850,
        300
      ]
    },
    {
      "parameters": {
        "operation": "upload",
        "bucketName": "={{$node[\"Set Variables\"].json.s3Bucket}}",
        "fileName": "cognitive-rhythm-dashboard.png",
        "binaryPropertyName": "data"
      },
      "name": "Upload to S3",
      "type": "n8n-nodes-base.s3",
      "typeVersion": 1,
      "position": [
        1050,
        300
      ]
    },
    {
      "parameters": {
        "variablesValues": {
          "s3Bucket": "pyragogy-dashboard",
          "dashboardUrl": "https://dashboard.pyragogy.org"
        }
      },
      "name": "Set Variables",
      "type": "n8n-nodes-base.set",
      "typeVersion": 1,
      "position": [
        250,
        150
      ]
    },
    {
      "parameters": {
        "to": "team@pyragogy.org",
        "subject": "Cognitive Rhythm Dashboard Update",
        "text": "=The Cognitive Rhythm Dashboard has been updated.\n\nSessions: {{$node[\"Prepare Chart Data\"].json.sessions}}\nData Points: {{$node[\"Prepare Chart Data\"].json.dataPoints}}\n\nView the dashboard at: {{$node[\"Set Variables\"].json.dashboardUrl}}\n\nThis is an automated message from the Pyragogy AI Village system.",
        "options": {
          "attachments": "data"
        }
      },
      "name": "Send Email",
      "type": "n8n-nodes-base.emailSend",
      "typeVersion": 1,
      "position": [
        1250,
        300
      ]
    }
  ],
  "connections": {
    "Schedule Trigger": {
      "main": [
        [
          {
            "node": "Get Metrics",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Get Metrics": {
      "main": [
        [
          {
            "node": "Prepare Chart Data",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Prepare Chart Data": {
      "main": [
        [
          {
            "node": "Generate Chart",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Generate Chart": {
      "main": [
        [
          {
            "node": "Upload to S3",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Upload to S3": {
      "main": [
        [
          {
            "node": "Send Email",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  }
}
```

## Risorse e Riferimenti

### Workflow Open Source

1. [Agentic Telegram AI bot with LangChain nodes and new tools](https://n8n.io/workflows/agentic-telegram-ai-bot-with-langchain-nodes-and-new-tools/)
   - Implementazione di un bot Telegram con capacità agentiche
   - Utilizza nodi LangChain per gestire il contesto e la memoria
   - Dimostra l'integrazione con strumenti esterni

2. [Reconcile Rent Payments with Local Excel Spreadsheet and OpenAI](https://n8n.io/workflows/reconcile-rent-payments-with-local-excel-spreadsheet-and-openai/)
   - Esempio di workflow che combina elaborazione dati e LLM
   - Mostra pattern di validazione e verifica
   - Utile per comprendere l'integrazione con dati strutturati

### Tutorial Video

1. [n8n AI Agent Tutorial | Building Multi Agent Workflows](https://www.youtube.com/watch?v=o2Pubq36Pao)
   - Tutorial completo sulla creazione di workflow multi-agente
   - Spiegazione passo-passo dell'implementazione
   - Dimostrazioni pratiche di orchestrazione

2. [Master Multi-AI Agent Workflows in N8N](https://www.youtube.com/watch?v=C-JBGZ56K5k)
   - Tecniche avanzate per workflow multi-agente
   - Ottimizzazione delle chiamate LLM
   - Strategie di scaling

### Articoli e Guide

1. [How to Build Multi-Agent AI Systems Using n8n and Google Gemini](https://datacouch.medium.com/how-to-build-multi-agent-ai-systems-using-n8n-and-google-gemini-8d6f3162c8b9)
   - Guida dettagliata all'implementazione di sistemi multi-agente
   - Esempi di integrazione con Google Gemini
   - Pattern di workflow e best practice

2. [9 AI Agent Frameworks Battle: Why Developers Prefer n8n](https://blog.n8n.io/ai-agent-frameworks/)
   - Confronto tra framework per agenti AI
   - Vantaggi di n8n per orchestrazione multi-agente
   - Casi d'uso e scenari di applicazione

### Community e Support

1. [n8n Community Forum](https://community.n8n.io/)
   - Discussioni e supporto dalla community
   - Esempi condivisi e soluzioni a problemi comuni
   - Aggiornamenti su nuove funzionalità e plugin

2. [n8n GitHub Repository](https://github.com/n8n-io/n8n)
   - Codice sorgente e documentazione
   - Issue tracker per problemi e richieste
   - Contributi della community
