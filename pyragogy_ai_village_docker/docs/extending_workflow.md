# Guida all'Estensione del Workflow Master n8n

Questo documento descrive come estendere il workflow master di Pyragogy AI Village aggiungendo nuovi agenti o modificando quelli esistenti.

## Struttura del Workflow Master

Il workflow master è progettato per essere altamente modulare e facilmente estensibile. La sua architettura è composta da:

1. **Trigger e Inizializzazione**: Webhook trigger e controllo della connessione al database
2. **Meta-orchestrator**: Determina la sequenza di agenti da eseguire
3. **Loop di Esecuzione Agenti**: Esegue ciascun agente in sequenza
4. **Routing Dinamico**: Indirizza l'input all'agente appropriato
5. **Persistenza**: Salva i risultati nel database e opzionalmente su GitHub
6. **Notifiche**: Invia notifiche via webhook o Slack

## Come Aggiungere un Nuovo Agente

Per aggiungere un nuovo agente al workflow, seguire questi passaggi:

### 1. Aggiungere il Nodo Condizionale

Dopo l'ultimo nodo condizionale esistente (attualmente "Is Archivist?"), aggiungere un nuovo nodo "If" con la seguente configurazione:

```
Nome: Is [NuovoAgente]?
Condizione: $json.agentToRun === "[NuovoAgente]"
```

### 2. Aggiungere il Nodo dell'Agente

Creare un nuovo nodo OpenAI (o altro tipo di nodo per l'elaborazione) con la seguente configurazione:

```
Nome: [NuovoAgente] Agent
Modello: gpt-4o (o altro modello appropriato)
Messaggio di sistema: "You are the [NuovoAgente]. [Descrizione del ruolo e delle responsabilità]."
Messaggio utente: "Input to process:\n{{ $json.agentInput }}"
```

### 3. Aggiornare il Nodo "Process Agent Output"

Modificare la funzione nel nodo "Process Agent Output" per includere il nuovo agente:

```javascript
// Aggiungi questa condizione all'interno della funzione
else if ($node["[NuovoAgente] Agent"] && $node["[NuovoAgente] Agent"]?.json?.choices?.[0]?.message?.content) {
  agentOutput = $node["[NuovoAgente] Agent"].json.choices[0].message.content;
}
```

### 4. Aggiornare il Prompt del Meta-orchestrator

Modificare il prompt del Meta-orchestrator per includere il nuovo agente nella lista degli agenti disponibili:

```
Available agents: Summarizer, Synthesizer, Peer Reviewer, Sensemaking Agent, Prompt Engineer, Onboarding/Explainer, Archivist, [NuovoAgente]
```

### 5. Collegare i Nodi

Collegare i nodi nel seguente modo:
- Dal ramo "False" del nodo condizionale precedente al nuovo nodo condizionale
- Dal ramo "True" del nuovo nodo condizionale al nodo dell'agente
- Dal ramo "False" del nuovo nodo condizionale al nodo condizionale successivo (o al nodo "Process Agent Output" se è l'ultimo)
- Dal nodo dell'agente al nodo "Process Agent Output"

## Esempio: Aggiungere un "Research Agent"

Ecco un esempio di come aggiungere un nuovo "Research Agent" che cerca informazioni su un argomento:

### 1. Nodo Condizionale

```
Nome: Is Research Agent?
Condizione: $json.agentToRun === "Research Agent"
```

### 2. Nodo dell'Agente

```
Nome: Research Agent
Modello: gpt-4o
Messaggio di sistema: "You are the Research Agent. Your task is to find and compile relevant information on the given topic, providing a comprehensive overview with key facts and insights."
Messaggio utente: "Topic to research:\n{{ $json.agentInput }}"
```

### 3. Aggiornamento del Nodo "Process Agent Output"

```javascript
// Aggiungi questa condizione
else if ($node["Research Agent"] && $node["Research Agent"]?.json?.choices?.[0]?.message?.content) {
  agentOutput = $node["Research Agent"].json.choices[0].message.content;
}
```

### 4. Aggiornamento del Meta-orchestrator

Aggiungere "Research Agent" alla lista degli agenti disponibili nel prompt del Meta-orchestrator.

## Aggiungere Funzionalità Avanzate

### Aggiungere Integrazione con API Esterne

Per agenti che necessitano di accedere a dati esterni, è possibile inserire nodi HTTP Request prima del nodo dell'agente:

```
[Is [NuovoAgente]?] (True) → [HTTP Request] → [[NuovoAgente] Agent] → [Process Agent Output]
```

### Aggiungere Human-in-the-Loop

Per inserire un punto di intervento umano:

1. Aggiungere un nodo "Wait" dopo l'esecuzione di un agente specifico
2. Configurare un webhook per ricevere l'input umano
3. Riprendere l'esecuzione del workflow con l'input umano

### Aggiungere Logica di Branching Complessa

Per logiche di decisione più complesse:

1. Aggiungere un nodo "Function" per implementare la logica personalizzata
2. Utilizzare nodi "Switch" per routing basato su più condizioni
3. Collegare i vari rami al flusso principale quando appropriato

## Best Practice

1. **Mantenere la Coerenza**: Seguire lo stesso pattern di denominazione e struttura per tutti gli agenti
2. **Documentare i Ruoli**: Aggiornare la documentazione con i nuovi agenti e i loro ruoli
3. **Testare Incrementalmente**: Testare ogni nuovo agente individualmente prima di integrarlo nel workflow completo
4. **Gestire il Contesto**: Assicurarsi che il contesto necessario venga passato correttamente tra gli agenti
5. **Monitorare le Performance**: Aggiungere metriche e logging per monitorare le performance dei nuovi agenti

## Limitazioni e Considerazioni

- Il workflow è progettato per eseguire gli agenti in sequenza, non in parallelo
- Ogni agente deve produrre un output che può essere utilizzato come input per l'agente successivo
- La dimensione del contesto è limitata, quindi è importante gestire efficacemente i dati tra gli agenti
- L'aggiunta di troppi agenti può aumentare il tempo di esecuzione complessivo del workflow
