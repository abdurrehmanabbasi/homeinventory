import 'package:flutter/material.dart';

class AnimatedListTile extends StatefulWidget {
  final String title;
  final imageBytes;
  final VoidCallback onDeletePressed;
  final VoidCallback onEditPressed;
  final VoidCallback onTapPressed;
  final bool loss;
  AnimatedListTile(
      {required this.title,
      required this.imageBytes,
      required this.onDeletePressed,
      required this.onEditPressed,
      required this.onTapPressed,
      this.loss = false});

  @override
  _AnimatedListTileState createState() => _AnimatedListTileState();
}

class _AnimatedListTileState extends State<AnimatedListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return FadeTransition(
      opacity: _animation,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(4),
        child: ListTile(
          leading: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
              maxWidth: 64,
              maxHeight: 64,
            ),
            child: Image.memory(widget.imageBytes, fit: BoxFit.cover),
          ),
          title: Text(widget.title),
          onTap: widget.onTapPressed,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Text(
                  '${widget.loss ? '*Lossed' : ''}',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              IconButton(
                color: Colors.blue,
                icon: Icon(Icons.edit),
                onPressed: widget.onEditPressed,
              ),
              IconButton(
                color: Colors.red,
                icon: Icon(Icons.delete),
                onPressed: widget.onDeletePressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
