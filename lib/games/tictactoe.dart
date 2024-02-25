import 'package:flutter/material.dart';

class TicTacToe extends StatefulWidget {
  @override
  _TicTacToeState createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  bool ohTurn = true; // first player is 'O'
  List<String> displayEx0h = ['', '', '', '', '', '', '', '', ''];

  var myTextStyle = TextStyle(color: Colors.white, fontSize: 30);
  int ohScore = 0;
  int exScore = 0;
  int filledBoxes = 0;

  bool _checkWinningCondition(String symbol) {
    // Check for winning conditions based on the provided symbol
    // You may need to customize this logic based on your game's rules

    // Example: Check for horizontal wins
    if ((displayEx0h[0] == symbol &&
            displayEx0h[1] == symbol &&
            displayEx0h[2] == symbol) ||
        (displayEx0h[3] == symbol &&
            displayEx0h[4] == symbol &&
            displayEx0h[5] == symbol) ||
        (displayEx0h[6] == symbol &&
            displayEx0h[7] == symbol &&
            displayEx0h[8] == symbol)) {
      return true;
    }

    // Example: Check for vertical wins
    if ((displayEx0h[0] == symbol &&
            displayEx0h[3] == symbol &&
            displayEx0h[6] == symbol) ||
        (displayEx0h[1] == symbol &&
            displayEx0h[4] == symbol &&
            displayEx0h[7] == symbol) ||
        (displayEx0h[2] == symbol &&
            displayEx0h[5] == symbol &&
            displayEx0h[8] == symbol)) {
      return true;
    }

    // Example: Check for diagonal wins
    if ((displayEx0h[0] == symbol &&
            displayEx0h[4] == symbol &&
            displayEx0h[8] == symbol) ||
        (displayEx0h[2] == symbol &&
            displayEx0h[4] == symbol &&
            displayEx0h[6] == symbol)) {
      return true;
    }

    // If no winning condition is met, return false
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(44, 37, 37, 37),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Player 1 :0',
                          style: myTextStyle,
                        ),
                        Text(
                          ohScore.toString(),
                          style: myTextStyle,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Player 2 : X',
                          style: myTextStyle,
                        ),
                        Text(
                          exScore.toString(),
                          style: myTextStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 9,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    _tapped(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[700]!),
                    ),
                    child: Center(
                      child: Text(
                        displayEx0h[index],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Text(
                      'TIC TAC TOE',
                      style: myTextStyle,
                    ),
                    SizedBox(
                      height: 60,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Center(
                child: ElevatedButton(
                  onPressed: _resetGame,
                  child: Text(
                    'Reset Game',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _tapped(int index) {
    setState(() {
      if (ohTurn && displayEx0h[index] == '') {
        displayEx0h[index] = 'O';
        filledBoxes += 1;
      } else if (!ohTurn && displayEx0h[index] == '') {
        displayEx0h[index] = 'X';
        filledBoxes += 1;
      }

      ohTurn = !ohTurn;

      if (_winnerFound()) {
        _showWinDialog(displayEx0h[index]);
      } else if (filledBoxes == 9) {
        _showDrawDialog();
      }
    });
  }

  bool _winnerFound() {
    return _checkWinningCondition('O') || _checkWinningCondition('X');
  }

  void _showWinDialog(String winner) {
    String loser =
        (winner == 'O') ? 'X' : 'O'; // Determine the loser based on the winner

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Winner is: $winner"),
          content: Text("Loser is: $loser"),
          actions: <Widget>[
            FloatingActionButton(
              child: Text('Play Again'),
              onPressed: () {
                _clearBoard();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (winner == 'O') {
      ohScore += 1;
    } else if (winner == 'X') {
      exScore += 1;
    }

    // Wait for a short period and then check for a tie
    Future.delayed(Duration(milliseconds: 1000), () {
      _checkForTie();
    });
  }

  void _checkForTie() {
    // Check if scores are equal
    if (ohScore == exScore) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("It's a Tie!"),
            content: Text("Both players have equal scores."),
            actions: <Widget>[
              FloatingActionButton(
                child: Text('Play Again'),
                onPressed: () {
                  _clearBoard();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _clearBoard() {
    setState(() {
      for (int i = 0; i < 9; i++) {
        displayEx0h[i] = '';
      }
    });
    filledBoxes = 0;
  }

  void _resetGame() {
    setState(() {
      // Reset all game-related variables and the game board
      ohTurn = true;
      ohScore = 0;
      exScore = 0;
      filledBoxes = 0;

      for (int i = 0; i < 9; i++) {
        displayEx0h[i] = '';
      }
    });
  }
  void _showDrawDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("It's a Draw!"),
        content: Text("No one wins this round."),
        actions: <Widget>[
          FloatingActionButton(
            child: Text('Play Again'),
            onPressed: () {
              _clearBoard();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
}
