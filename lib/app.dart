import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:health_code/liffecycle_event_handler.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Uri _url =
      Uri.parse('https://app.ssm.gov.mo/healthPHD/page/index.html');
  late InAppWebViewController _controller;
  late WidgetsBindingObserver _observer;
  bool _auto = true;

  @override
  void initState() {
    super.initState();
    _observer = LifecycleEventHandler(
      resumeCallBack: () async {
        await _controller.evaluateJavascript(source: _script);
        await _controller.loadUrl(urlRequest: URLRequest(url: _url));
      },
    );
    WidgetsBinding.instance.addObserver(_observer);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_observer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: _url,
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
              },
              onLoadStop: (controller, uri) async {
                await _controller.evaluateJavascript(source: _script);
              },
            ),
            // Reload
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () async => await _controller.loadUrl(
                    urlRequest: URLRequest(url: _url)),
                child: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: GestureDetector(
                onTap: () async {
                  await _controller.loadUrl(urlRequest: URLRequest(url: _url));
                  setState(() {
                    _auto = !_auto;
                  });
                },
                child: Text(_auto ? 'AUTO' : 'MANUAL'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _script {
    return """
        var idCardJsonString = localStorage.getItem('saveSubmitUser');

        if (idCardJsonString !== null) {
            var idCards = JSON.parse(idCardJsonString);
            if (idCards.length != 0) {
                var idCard = idCards[0];
                var localeStorageKey = 'healthdeclaration' + idCard;
                var jsonString = localStorage.getItem(localeStorageKey);
                var rawData = JSON.parse(jsonString);
                // rawData['creationDate'] = new Date(Date.now() - 86400000).getTime();
                rawData['creationDate'] = Date.now();
                var newData = JSON.stringify(rawData);
                localStorage.setItem(localeStorageKey, newData);

                $_autoClick
                
            }
        }
    """;
  }

  String get _autoClick {
    if (_auto) {
      return """
      setTimeout(function() {
          window.frames[0].document.querySelector('#btnReset.btn-info').click();
      }, 500);
      """;
    }
    return '';
  }
}
