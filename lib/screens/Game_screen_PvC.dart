import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'dart:math'; // Import Random

class GamePagePVC extends StatefulWidget {
  @override
  _GamePagePVCState createState() => _GamePagePVCState();
}

class _GamePagePVCState extends State<GamePagePVC> {
  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  String _winner = '';
  bool _gameOver = false;
  bool? _vibrationEnabled;
  bool _isComputerTurn = false; // Track if it's the computer's turn
  final Random _random = Random(); // Create a Random instance

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    });
  }

  void _handleTap(int index) {
    if (_board[index] == '' && !_gameOver && !_isComputerTurn) {
      setState(() {
        _board[index] = _currentPlayer;
        if (_vibrationEnabled == true) {
          Vibration.vibrate(duration: 50);
        }
        if (_checkWin()) {
          _winner = _currentPlayer;
          _gameOver = true;
          _showWinDialog(_currentPlayer);
        } else if (_board.every((cell) => cell != '')) {
          _winner = 'Tie';
          _gameOver = true;
          _showWinDialog('Tie');
        } else {
          _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
          if (_currentPlayer == 'O') {
            _isComputerTurn = true;
            _computerMove();
          }
        }
      });
    }
  }

  void _computerMove() async {
    await Future.delayed(Duration(milliseconds: 700));
    int move = _findBestMove();
    setState(() {
      _board[move] = 'O';
      if (_vibrationEnabled == true) {
        Vibration.vibrate(duration: 50);
      }
      if (_checkWin()) {
        _winner = 'O';
        _gameOver = true;
        _showWinDialog('O');
      } else if (_board.every((cell) => cell != '')) {
        _winner = 'Tie';
        _gameOver = true;
        _showWinDialog('Tie');
      } else {
        _currentPlayer = 'X';
        _isComputerTurn = false;
      }
    });
  }

  int _findBestMove() {
    // Check for a winning move
    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') {
        _board[i] = 'O';
        if (_checkWin()) {
          _board[i] = '';
          return i;
        }
        _board[i] = '';
      }
    }

    // Check for a blocking move
    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') {
        _board[i] = 'X';
        if (_checkWin()) {
          _board[i] = '';
          return i;
        }
        _board[i] = '';
      }
    }

    // If no winning or blocking move, pick a random move
    List<int> availableMoves = [];
    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') {
        availableMoves.add(i);
      }
    }
    return availableMoves.isNotEmpty ? availableMoves[_random.nextInt(availableMoves.length)] : 0;
  }

  bool _checkWin() {
    final winningCombos = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var combo in winningCombos) {
      if (_board[combo[0]] != '' &&
          _board[combo[0]] == _board[combo[1]] &&
          _board[combo[1]] == _board[combo[2]]) {
        return true;
      }
    }
    return false;
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = 'X';
      _winner = '';
      _gameOver = false;
      _isComputerTurn = false;
    });
  }

  void _showWinDialog(String winner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(winner == 'Tie' ? 'It\'s a Tie!' : 'Player $winner Wins!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false, // This removes the back button
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              if (_vibrationEnabled == true) {
                Vibration.vibrate(duration: 50);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _winner == ''
                  ? 'Current Player: $_currentPlayer'
                  : _winner == 'Tie'
                      ? 'It\'s a Tie!'
                      : 'Player $_winner Wins!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _handleTap(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              _board[index],
                              style: TextStyle(
                                fontSize: 50,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: _board[index] == 'X'
                                    ? [
                                        Shadow(
                                          blurRadius: 15.0,
                                          color: Colors.red,
                                          offset: Offset(3, 0),
                                        ),
                                      ]
                                    : _board[index] == 'O'
                                        ? [
                                            Shadow(
                                              blurRadius: 15.0,
                                              color: Colors.yellow,
                                              offset: Offset(2, 0),
                                            ),
                                          ]
                                        : [],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  IgnorePointer(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: GridPainter(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;

    final cellSize = size.width / 3;

    for (int i = 1; i < 3; i++) {
      // Draw horizontal lines
      canvas.drawLine(
        Offset(0, cellSize * i),
        Offset(size.width, cellSize * i),
        paint,
      );
      // Draw vertical lines
      canvas.drawLine(
        Offset(cellSize * i, 0),
        Offset(cellSize * i, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
