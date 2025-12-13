import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// A small widget that shows current connectivity.
///
/// Use `OnlineIndicator()` to render a compact icon, or
/// `OnlineIndicator(asCard: true)` to render a Card with details and action.
class OnlineIndicator extends StatefulWidget {
  final bool asCard;

  const OnlineIndicator({Key? key, this.asCard = false}) : super(key: key);

  @override
  State<OnlineIndicator> createState() => _OnlineIndicatorState();
}

class _OnlineIndicatorState extends State<OnlineIndicator> {
  bool _isOnline = true;
  // Newer versions of connectivity_plus emit a List<ConnectivityResult>
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void initState() {
    super.initState();
    // get initial state
    Connectivity().checkConnectivity().then((result) {
      if (mounted) {
        setState(() => _isOnline = _toOnline(result));
      }
    });
    // listen for subsequent changes
    _sub = Connectivity().onConnectivityChanged.listen((result) {
      if (!mounted) return;
      setState(() => _isOnline = _toOnline(result));
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _tryReconnect() async {
    final result = await Connectivity().checkConnectivity();
    final nowOnline = _toOnline(result);
    if (!mounted) return;
    setState(() => _isOnline = nowOnline);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(nowOnline ? 'Reconnected' : 'Still offline')),
    );
  }

  // Convert connectivity result(s) to a simple online/offline boolean.
  bool _toOnline(dynamic result) {
    if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }
    if (result is List<ConnectivityResult>) {
      return result.any((r) => r != ConnectivityResult.none);
    }
    return _isOnline;
  }

  @override
  Widget build(BuildContext context) {
    const Color onlineColor = Colors.green;
    const Color offlineColor = Colors.red;

    if (widget.asCard) {
      return Card(
        color: _isOnline ? onlineColor : offlineColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _isOnline ? onlineColor : offlineColor,
            radius: 10,
          ),
          title: Text(
            _isOnline ? 'Connected to network' : 'Offline',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          trailing: TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: _tryReconnect,
            child: Text(_isOnline ? 'Refresh' : 'Try Connect'),
          ),
        ),
      );
    }

    return Icon(
      _isOnline ? Icons.wifi : Icons.wifi_off,
      color: _isOnline ? onlineColor : offlineColor,
    );
  }
}
