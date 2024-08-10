import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class GamePagePVC extends StatefulWidget {
  @override
  _GamePagePVCState createState() => _GamePagePVCState();
}

class _GamePagePVCState extends State<GamePagePVC> {
  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  String _winner = '';
  bool _gameOver = false;
  bool? _soundEnabled;
  bool? _vibrationEnabled;
  AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    });
  }

  void _playSound(String soundName) async {
    if (_soundEnabled == true) {
      await _audioPlayer.play(AssetSource('sounds/$soundName.wav'));
    }
  }

  void _handleTap(int index) {
    if (_board[index] == '' && !_gameOver) {
      setState(() {
        _board[index] = _currentPlayer;
        if (_vibrationEnabled == true) {
          Vibration.vibrate(duration: 50);
        }
        _playSound('move');
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
            _computerMove();
          }
        }
      });
    }
  }

  void _computerMove() {
    int move = _findBestMove();
    _handleTap(move);
  }

  int _findBestMove() {
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
    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') {
        return i;
      }
    }
    return 0;
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
