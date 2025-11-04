# Mastermind mini #

Nome: Samuele
Cognome: Tavani

Descrizione breve: 
Questo progetto è una piccola implementazione del gioco mastermind, sviluppata su flutter

Caratteristiche principali:
- Logica Algoritmica: Algoritmo a doppio passaggio per il conteggio dei pioli di feedback

- Gestione Stato: Semplice e pulita, isolata nel widget principale (_MyHomePageState)

- Design Responsive: Layout ottimizzato per evitare overflow su schermi di diverse dimensioni

- Feedback Visivo: Pioli di feedback con colorazione personalizzata (Verde e Giallo)

Scelte di sviluppo:

  Archittettura:
    dato che non ho aggiunto altri schermi ho gestito tutto con un StatefulWidget con setState() dato che è più semplice da usarlo che in altri modi
  Algoritmo di feedback:
    L'algroritmo calcola i pioli "neri" (quelli verdi in questa versione), poi utilizza copie delle liste per eliminare i colori già contati così si evita alla fine un doppio conteggio
  Leggibilità:
    Il codice è pulito nel senso che molte funzioni sono scritte separatemente per un maggior ordine mentale ed è più facile trovare eventuali errori

