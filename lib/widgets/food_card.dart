import 'package:flutter/material.dart';
import '../models/food.dart';
import '../theme/theme.dart';

class FoodCard extends StatefulWidget {
  final Food food;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const FoodCard({
    super.key,
    required this.food,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> with TickerProviderStateMixin {
  late AnimationController _returnController;
  late AnimationController _deleteController;
  late Animation<Offset> _returnAnimation;
  late Animation<double> _deleteAnimation;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  String? _dragDirection;
  late double _cardWidth;

  static const double _thresholdRatio = 0.33;

  @override
  void initState() {
    super.initState();
    _returnController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _deleteController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _returnAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _returnController, curve: Curves.easeOut),
        );

    _deleteAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _deleteController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _returnController.dispose();
    _deleteController.dispose();
    super.dispose();
  }

  String get _expiryStatus {
    if (widget.food.expiryDate == null) return 'no expiry date';
    if (widget.food.isExpired) return 'expired';

    final daysLeft = widget.food.daysUntilExpiry;

    if (daysLeft == 0) return 'expires today';
    if (daysLeft == 1) return 'expires tomorrow';

    return 'expires in $daysLeft days';
  }

  Color get _expiryColor {
    if (widget.food.expiryDate == null) return Colors.grey;
    if (widget.food.isExpired) return Colors.red;
    if (widget.food.daysUntilExpiry! <= 3) return Colors.orange;
    return Colors.green;
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _isDragging = true;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      _dragOffset = Offset(_dragOffset.dx + details.delta.dx, 0);
      if (_dragOffset.dx > 0) {
        _dragDirection = 'left';
      } else if (_dragOffset.dx < 0) {
        _dragDirection = 'right';
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isDragging) {
      _isDragging = false;
      return;
    }

    _isDragging = false;
    final threshold = _cardWidth * _thresholdRatio;
    final currentDistance = _dragOffset.dx.abs();

    if (currentDistance >= threshold) {
      if (_dragDirection == 'left' && _dragOffset.dx > 0) {
        widget.onEdit();
        _animateReturn();
      } else if (_dragDirection == 'right' && _dragOffset.dx < 0) {
        _animateDelete();
      } else {
        _animateReturn();
      }
    } else {
      _animateReturn();
    }
  }

  void _animateReturn() {
    _returnAnimation = Tween<Offset>(begin: _dragOffset, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _returnController, curve: Curves.easeOut),
        );

    _returnController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() => _dragOffset = Offset.zero);
      }
    });
  }

  void _animateDelete() {
    _deleteAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _deleteController, curve: Curves.easeOut),
    );

    _deleteController.forward(from: 0).then((_) {
      widget.onDelete();
    });
  }

  double _getIconOpacity() {
    if (_cardWidth == 0) return 0;
    final threshold = _cardWidth * _thresholdRatio;
    final currentDistance = _dragOffset.dx.abs();
    return (currentDistance / threshold).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _deleteAnimation.value,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _cardWidth = constraints.maxWidth;
          return Stack(
            children: [
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: Opacity(
                        opacity: _dragDirection == 'left'
                            ? _getIconOpacity()
                            : 0,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Opacity(
                        opacity: _dragDirection == 'right'
                            ? _getIconOpacity()
                            : 0,
                        child: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: _returnController.isAnimating
                    ? _returnAnimation.value
                    : _dragOffset,
                child: GestureDetector(
                  onHorizontalDragStart: _onHorizontalDragStart,
                  onHorizontalDragUpdate: _onHorizontalDragUpdate,
                  onHorizontalDragEnd: _onHorizontalDragEnd,
                  child: Card(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.food.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                   Icon(
                                     Icons.scale,
                                     size: 16,
                                     color: AppColors.accentOrange,
                                   ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${widget.food.quantity} ${widget.food.unit}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: _expiryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _expiryStatus,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: _expiryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
