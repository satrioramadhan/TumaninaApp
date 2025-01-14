import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class GerakanDetailScreen extends StatefulWidget {
  final String title;
  final String description;
  final String bacaan;
  final String videoUrl;
  final Widget? nextScreen;
  final Widget? previousScreen;

  const GerakanDetailScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.bacaan,
    required this.videoUrl,
    this.nextScreen,
    this.previousScreen,
  }) : super(key: key);

  @override
  _GerakanDetailScreenState createState() => _GerakanDetailScreenState();
}

class _GerakanDetailScreenState extends State<GerakanDetailScreen> {
  late final WebViewController _webViewController;

  Future<void> _launchURL() async {
  final Uri url = Uri.parse("https://deteksi.tumanina.me/");
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Gagal membuka URL');
  }
}

  @override
  void initState() {
    super.initState();

    // Initialize WebViewController
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(widget.videoUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 84, 123, 85),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildBubbleContainer(
                title: "Cara Melakukan Gerakan",
                content: widget.description,
              ),
              const SizedBox(height: 20),
              _buildBubbleContainer(
                title: "Bacaan Gerakan",
                content: widget.bacaan,
              ),
              const SizedBox(height: 20),
              _buildBubbleContainer(
                title: "Video Tutorial",
                content: null,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: WebViewWidget(controller: _webViewController),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _launchURL,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
                child: const Text(
                  "Praktek Gerakan",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildNavigationBubble(
                      "Sebelumnya",
                      widget.previousScreen,
                      context,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildNavigationBubble(
                      "Selanjutnya",
                      widget.nextScreen,
                      context,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubbleContainer({
    required String title,
    String? content,
    Widget? child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 63, 63, 63),
            ),
          ),
          const SizedBox(height: 10),
          if (content != null)
            Text(
              content,
              style: const TextStyle(
                fontSize: 16.0,
                color: Color.fromARGB(179, 35, 35, 35),
              ),
            ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildNavigationBubble(String label, Widget? screen, BuildContext context) {
    return GestureDetector(
      onTap: screen != null
          ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen!))
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        decoration: BoxDecoration(
          color: screen != null ? const Color.fromARGB(255, 125, 179, 133) : Colors.grey,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class WebViewScreen extends StatelessWidget {
  final String url;

  const WebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "WebView",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 84, 123, 85),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..loadRequest(Uri.parse(url)),
      ),
    );
  }
}
