import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe',
      home: TicTacToeGame(),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  late List<List<String>> board;
  late String currentPlayer;
  String? winner;

  late Timer timer;
  int countdown = 10;

  int player1Wins = 0;
  int player2Wins = 0;
  int drawCount = 0;

  bool botPlay = false;

  @override
  void initState() {
    super.initState();
    initializeBoard();
    startTimer();
  }

  void initializeBoard() {
    board = List.generate(3, (_) => List<String>.filled(3, ""));
    currentPlayer = "X";
    winner = null;
  }

  void makeMove(int row, int col) {
    if (board[row][col] == "" && winner == null) {
      setState(() {
        board[row][col] = currentPlayer;
        if (checkForWinner(row, col)) {
          winner = currentPlayer;
          updateWinnerCount();
          timer.cancel();
        } else if (isBoardFull()) {
          // Draw
          drawCount++;
          timer.cancel();
        } else {
          currentPlayer = (currentPlayer == "X") ? "O" : "X";
          if (botPlay &&
              currentPlayer == "O" &&
              !isBoardFull() &&
              winner == null) {
            makeBotMove();
          }
        }
      });
    }
  }

  void makeBotMove() {
    // Simple bot logic: Finds the first empty cell and makes a move
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == "") {
          makeMove(i, j);
          return;
        }
      }
    }
  }

  bool checkForWinner(int row, int col) {
    // Check row
    if (board[row][0] == currentPlayer &&
        board[row][1] == currentPlayer &&
        board[row][2] == currentPlayer) {
      return true;
    }
    // Check column
    if (board[0][col] == currentPlayer &&
        board[1][col] == currentPlayer &&
        board[2][col] == currentPlayer) {
      return true;
    }
    // Check diagonals
    if ((board[0][0] == currentPlayer &&
            board[1][1] == currentPlayer &&
            board[2][2] == currentPlayer) ||
        (board[0][2] == currentPlayer &&
            board[1][1] == currentPlayer &&
            board[2][0] == currentPlayer)) {
      return true;
    }
    return false;
  }

  void resetGame() {
    setState(() {
      initializeBoard();
      startTimer();
    });
  }

  void startTimer() {
    countdown = 10;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown <= 0) {
          timer.cancel();
        } else {
          countdown--;
        }
      });
    });
  }

  bool isBoardFull() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == "") {
          return false;
        }
      }
    }
    return true;
  }

  void updateWinnerCount() {
    if (winner == "X") {
      player1Wins++;
    } else if (winner == "O") {
      player2Wins++;
    }
  }

  Widget buildTile(int row, int col) {
    return GestureDetector(
        onTap: () => makeMove(row, col),
        child: Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              color: const Color.fromARGB(255, 255, 255, 255)),
          child: Center(
            child: Text(
              board[row][col],
              style: TextStyle(
                fontSize: 50.0,
                fontFamily: 'RubikMaps',
                color: board[row][col] == 'X' ? Colors.red : Colors.lightBlue,
              ),
            ),
          ),
        ));
  }

  Color getTextColor() {
    if (countdown > 5) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool exitConfirmed = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App?'),
            content: const Text('Do you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (exitConfirmed == true) {
          SystemNavigator.pop();
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF274C43),
          title: const Text(
            'Tic Tac Toe',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'RubikMaps',
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20.0),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      'O',
                      style: TextStyle(
                          fontSize: 50.0,
                          fontFamily: 'RubikMaps',
                          color: Colors.lightBlue),
                    ),
                    Text(
                      '-',
                      style: TextStyle(
                          fontSize: 50.0,
                          fontFamily: 'RubikMaps',
                          color: Colors.black),
                    ),
                    Text(
                      'X',
                      style: TextStyle(
                          fontSize: 50.0,
                          fontFamily: 'RubikMaps',
                          color: Colors.red),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      '$player2Wins Wins',
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      '$drawCount Draws',
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      '$player1Wins Wins',
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Text(
                  '$countdown',
                  style: TextStyle(
                    fontSize: 50.0,
                    color: getTextColor(),
                    fontFamily: 'RubikMaps',
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  (winner != null)
                      ? '$winner wins!'
                      : (isBoardFull() ? 'Draw!' : 'Player: $currentPlayer'),
                  style: TextStyle(
                    fontSize: 50.0,
                    fontFamily: 'RubikMaps',
                    color: (winner != null)
                        ? (winner == 'O' ? Colors.blue : Colors.red)
                        : (isBoardFull() ? Colors.orange : Colors.black),
                  ),
                ),
                const SizedBox(height: 20.0),
                Column(
                  children: List.generate(
                    3,
                    (row) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (col) => buildTile(row, col),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          botPlay = !botPlay;
                          if (botPlay && currentPlayer == "O") {
                            makeBotMove();
                          }
                        });
                      },
                      tooltip: 'Enable/Disable Bot',
                      backgroundColor: Colors.white,
                      child: botPlay
                          ? Image.asset(
                              'assets/bot2.png',
                              width:
                                  50, // Set the width and height based on your image size
                              height: 50,
                            )
                          : Image.asset(
                              'assets/bot1.png', // Replace with your outlined robot image if available
                              width: 50,
                              height: 50,
                            ),
                    ),
                    const SizedBox(height: 1.0),
                    const SizedBox(height: 1.0),
                    const SizedBox(height: 1.0),
                    FloatingActionButton(
                      onPressed: resetGame,
                      tooltip: 'Restart Game',
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.restart_alt_sharp,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
