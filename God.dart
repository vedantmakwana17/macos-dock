import 'package:flutter/material.dart';

void main() => runApp(const God());

class God extends StatelessWidget {
  const God({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 50),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock<T extends IconData> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T extends IconData> extends State<Dock<T>> {
  late final List<T> _items = widget.items.toList();
  double dockPosition = 0.0;
  double dockScale = 1.0;
  double maxDrag = 300.0;
  final double itemScaleOnHover = 1.2;
  final Set<int> _hoveredIndices = {};

  void _onDockDragUpdate(DragUpdateDetails details) {
    setState(() {
      dockPosition += details.primaryDelta!;
      if (dockPosition < -maxDrag) dockPosition = -maxDrag;
      if (dockPosition > maxDrag) dockPosition = maxDrag;
    });
  }

  void _onDockDragEnd(DragEndDetails details) {
    setState(() {
      dockPosition = dockPosition.roundToDouble();
      if (dockPosition > 0) {
        dockPosition = 0;
      } else if (dockPosition < 0) {
        dockPosition = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onDockDragUpdate,
      onHorizontalDragEnd: _onDockDragEnd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black12,
        ),
        transform: Matrix4.translationValues(dockPosition, 0.0, 0.0),
        child: MouseRegion(
          onEnter: (_) {
            setState(() {
              dockScale = 1.05;
            });
          },
          onExit: (_) {
            setState(() {
              dockScale = 1.0;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            transform: Matrix4.identity()..scale(dockScale),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_items.length, (index) {
                return MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _hoveredIndices.add(index);
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _hoveredIndices.remove(index);
                    });
                  },
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: _hoveredIndices.contains(index) ? itemScaleOnHover : 1.0,
                    child: Draggable<T>(
                      data: _items[index],
                      feedback: Material(
                        color: Colors.transparent,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 50),
                          height: 48,
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.primaries[
                            _items[index].hashCode % Colors.primaries.length],
                          ),
                          child: Center(child: Icon(_items[index], color: Colors.white)),
                        ),
                      ),
                      childWhenDragging: Container(
                        height: 50,
                      ),
                      child: DragTarget<T>(
                        onAcceptWithDetails: (details) {
                          setState(() {
                            final fromIndex = _items.indexOf(details.data);
                            final toIndex = index;
                            if (fromIndex != toIndex) {
                              final temp = _items[fromIndex];
                              _items[fromIndex] = _items[toIndex];
                              _items[toIndex] = temp;
                            }
                          });
                        },
                        builder: (context, candidateData, rejectedData) {
                          return widget.builder(_items[index]);
                        },
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
