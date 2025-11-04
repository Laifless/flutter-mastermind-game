import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mastermind',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(title: 'Mastermind Game'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  // Lista dei colori disponibili nel gioco (incluso il grigio iniziale 'vuoto')
  final List <Color> _colorChoice = const [
    Colors.grey, // 0: Colore "iniziale" o vuoto
    Colors.red,
    Colors.green,
    Colors.blue, 
    Colors.yellow,
    Colors.purple,
    Colors.pink,
    Colors.orange
  ];
  
  // STATO ESSENZIALE: RIGA ATTIVA che l'utente sta modificando
  List <Color> _activeGuess = [
    Colors.grey,
    Colors.grey,
    Colors.grey,
    Colors.grey
  ];

  // Codice segreto generato
  List<Color> _secretCode = [];
  
  // Cronologia dei tentativi passati (le righe "non toccabili")
  final List<List<Color>> _pastGuesses = [];
  // Cronologia dei feedback (pioli neri/bianchi) per ogni tentativo passato
  final List<List<Color>> _pastFeedbacks = [];
  
  final int _maxGuesses = 10; // Numero massimo di tentativi
  bool _gameWon = false; // Stato di vittoria
  bool _gameLost = false; // Stato di sconfitta

  @override
  void initState() {
    super.initState();
    _generateSecretCode(); // Genera il codice all'avvio
  }
  
  // Funzione per generare il codice segreto (4 colori a caso tra i colori "veri")
  void _generateSecretCode() {
    final Random random = Random();
    final List<Color> realColors = _colorChoice.sublist(1); // Esclude il grigio
    
    _secretCode = List.generate(4, (_) {
      return realColors[random.nextInt(realColors.length)];
    });
    print('Secret Code (Debug): $_secretCode'); 
  }

  // Funzione per resettare il gioco (chiamata dal Dialog)
  void _resetGame() {
    Navigator.of(context).pop(); // Chiude il dialog
    setState(() {
      _pastGuesses.clear();
      _pastFeedbacks.clear();
      _activeGuess = [Colors.grey, Colors.grey, Colors.grey, Colors.grey];
      _gameWon = false;
      _gameLost = false;
      _generateSecretCode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary, 
      ),
      body: Column(
        children: [
          // Cronologia dei tetativi
          Expanded(
            //Disegna la lista dei tentativi passati
            child: ListView.builder(
              itemCount: _pastGuesses.length,
              itemBuilder: (context, index) {
                // Chiama la funzione helper per disegnare una riga passata
                return _buildPastGuessRow(
                  _pastGuesses[index], 
                  _pastFeedbacks[index]
                );
              },
            ),
          ),
          
          const Divider(),

          //  Riga interattiva
          _buildActiveGuessRow(), // Chiama la funzione helper per la riga cliccabile

          const SizedBox(height: 20),
          
          // BOTTONE DI VERIFICA
          ElevatedButton(
            // Il bottone chiama la nuova logica _checkGuess
            onPressed: (_gameWon || _gameLost) ? null : _checkGuess, // Disabilita se il gioco è finito
            child: const Text('Check Guess'),
          ),

          const SizedBox(height: 20),
          /*
          // Visualizzazione temporanea del codice segreto (per debug)
          const Text('Secret Code (Debug):'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _secretCode.map((color) => Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(Icons.circle, color: color, size: 20),
            )).toList(),
          ),
          const SizedBox(height: 20),
        */
        ]
      ),
    );
  }

  // --- WIDGET HELPER (nuove funzioni per mantenere pulito il build) ---

  //La riga interattiva
  Widget _buildActiveGuessRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.brown.withOpacity(0.1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: _activeGuess.asMap().entries.map((entry) {
          final index = entry.key;
          final color = entry.value;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: IconButton(
              // Disabilita i bottoni se il gioco è finito
              onPressed: (_gameWon || _gameLost) ? null : () => _changeColor(index),
              icon: const Icon(Icons.circle),
              color: color, 
              iconSize: 50,
            ),
          );
        }).toList(),
      ),
    );
  }
  
  // Costruisce una riga di cronologia statica 
  Widget _buildPastGuessRow(List<Color> guess, List<Color> feedback) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.brown[200],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: guess.map((color) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
        
                child: Icon(Icons.circle, color: color, size: 40),
              )).toList(),
            ),
          ),
          
          const SizedBox(width: 20),
          
          // 2. I pioli di feedback
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black45),
              borderRadius: BorderRadius.circular(8),
            ),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                // Visualizza i pioli di feedback (neri o bianchi)
                Color feedbackColor = index < feedback.length 
                    ? feedback[index] 
                    : Colors.transparent; // Spazi vuoti
                return Container(
                  decoration: BoxDecoration(
                    color: feedbackColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12, width: 0.5)
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGICA DI GIOCO ---

  // Logica per ciclare il colore della pedina all'indice selezionato
  void _changeColor(int index){
    if (_gameWon || _gameLost) return; 

    setState(() {
      Color currentColor = _activeGuess[index]; 
      int currentIndex = _colorChoice.indexOf(currentColor); 
      int nextIndex = (currentIndex + 1) % _colorChoice.length; 
      _activeGuess[index] = _colorChoice[nextIndex]; 
    });
  }

  // Logica di verifica del gioco 
  void _checkGuess() {
    if (_gameWon || _gameLost) return;
    
    // Controlla che tutte le pedine siano state selezionate
    if (_activeGuess.contains(Colors.grey)) {
      
      print("Riga non completa!"); 
      return;
    }

    // === ALGORITMO DI CALCOLO PIOLI NERI E BIANCHI ===
    List<Color> feedback = [];
    // ho dichiarato le due variabili whitePegs e blackPegs nonostante non sinao bianche e nere, ho deciso di chiamarle così per la logica di gioco
    //facendo venire più facile da intuire il verde e il giallo
    int blackPegs = 0; // Colore giusto, posizione giusta (verde)
    int whitePegs = 0; // Colore giusto, posizione sbagliata (giallo)

    // Usiamo copie per non modificare gli originali
    List<Color> guessCopy = List.from(_activeGuess);
    List<Color> secretCopy = List.from(_secretCode);

    //Calcola i pioli NERI (posizione e colore giusti)
    for (int i = 0; i < 4; i++) {
      if (guessCopy[i] == secretCopy[i]) {
        blackPegs++;
        feedback.add(const Color.fromARGB(255, 40, 122, 19));
        // "Elimina" questi colori per non contarli di nuovo
        guessCopy[i] = Colors.transparent; 
        secretCopy[i] = Colors.transparent;
      }
    }

    //Calcola i pioli BIANCHI (colore giusto, posizione sbagliata)
    for (int i = 0; i < 4; i++) {
      if (guessCopy[i] != Colors.transparent) { // Ignora quelli già contati
        for (int j = 0; j < 4; j++) {
          if (secretCopy[j] != Colors.transparent && guessCopy[i] == secretCopy[j]) {
            whitePegs++;
            feedback.add(const Color.fromARGB(255, 169, 172, 14));
            // "Elimina" il colore dal codice segreto per non riusarlo
            secretCopy[j] = Colors.transparent;
            break; // Passa al prossimo colore del tentativo
          }
        }
      }
    }
    
    // --- AGGIORNA STATO GIOCO ---
    setState(() {
      //Aggiungi il tentativo e il feedback alla cronologia
      _pastGuesses.add(List.from(_activeGuess));
      _pastFeedbacks.add(feedback);

      // Controlla la VITTORIA
      if (blackPegs == 4) {
        _gameWon = true;
        _showGameEndDialog("Hai vinto!", "Complimenti, hai indovinato!");
      } 
      // Controlla la SCONFITTA
      else if (_pastGuesses.length >= _maxGuesses) {
        _gameLost = true;
        _showGameEndDialog("Hai perso!", "Hai finito i tentativi. Il codice era: ${_secretCode.map((c) => c.toString().split('.').last).join(', ')}");
      } 
      // reset della riga per il prossimo tentativo
      else {
        _activeGuess = [Colors.grey, Colors.grey, Colors.grey, Colors.grey];
      }
    });
  }

  // Mostra il dialog di fine gioco (nuova funzione)
  void _showGameEndDialog(String title, String content) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: _resetGame, 
              child: const Text('Gioca di nuovo'),
            ),
          ],
        );
      },
    );
  }
}