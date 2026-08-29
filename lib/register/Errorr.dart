import 'package:flutter/material.dart';

class ErrorMessageWidget extends StatefulWidget {
  final String errorMessage;
  final VoidCallback? onDismissed;
  const ErrorMessageWidget(
      {super.key, required this.errorMessage, this.onDismissed});

  @override
  State<ErrorMessageWidget> createState() => _ErrorMessageWidgetState();
}

class _ErrorMessageWidgetState extends State<ErrorMessageWidget> {
  bool _isVisible = false;

  void _dismiss() {
    setState(() {
      _isVisible = false;
    });
  }

  void _showErrorMessage() {
    setState(() {
      _isVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _dismiss,
      child: SizedBox(
        // height: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 30,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              color: const Color(0x1AEF4444),
              border: Border.all(width: 1, color: const Color(0xffEF4444)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xffEF4444),
                  size: 20,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                    child: Text(
                  widget.errorMessage,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xffEF4444)),
                )),
                // GestureDetector(
                //   onTap: _dismiss,
                //   child: const Icon(
                //     Icons.close_rounded,
                //     color: Color(0xFFE53935),
                //     size: 20.0,
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
