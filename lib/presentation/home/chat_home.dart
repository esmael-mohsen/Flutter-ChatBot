import 'dart:io';

import 'package:chat_bot/common/helper/theme_provider.dart';
import 'package:chat_bot/core/assets/app_images.dart';
import 'package:chat_bot/core/config/app_color.dart';
import 'package:chat_bot/domain/entities/masseges/masseges_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  final List<MassegesEntities> _messages = [];

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage; // ✅ Selected image

  /// 📸 Pick Image from Gallery or Camera
  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  String formatAIResponse(String rawText) {
    List<String> lines = rawText.split('\n'); // ✅ Split text into lines
    String formattedText = '';

    for (String line in lines) {
      if (line.startsWith('Here\'s')) {
        formattedText += '**🔹 ${line.trim()}**\n\n'; // ✅ Bold Titles
      } else if (line.startsWith('* ')) {
        formattedText += '🔸 ${line.substring(2).trim()}\n'; // ✅ Bullet Points
      } else if (line.contains(':')) {
        formattedText += '**${line.trim()}**\n'; // ✅ Bold Subtitles
      } else {
        formattedText += '${line.trim()}\n'; // ✅ Normal Text
      }
    }

    return formattedText.trim();
  }

  /// 📤 Send Message with Text or Image
  Future<void> callGeminiModel() async {
    try {
      final userInput = _controller.text.trim();
      if (userInput.isEmpty && _selectedImage == null) return;

      setState(() {
        _messages.add(
          MassegesEntities(
            massege: userInput,
            image: _selectedImage,
            isSender: true,
          ),
        );
        _listKey.currentState?.insertItem(_messages.length - 1);
        _controller.clear();
        _isLoading = true;
      });

      final apiKey = dotenv.env['GOOGLE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        print("Error: GOOGLE_API_KEY is missing.");
        setState(() => _isLoading = false);
        return;
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-flash', // ✅ Updated to latest model
        apiKey: apiKey,
      );

      final List<Content> content = [Content.text(userInput)];
      if (_selectedImage != null) {
        final imageBytes = await _selectedImage!.readAsBytes();
        content.add(Content.data('image/png', imageBytes));
      }

      final response = await model.generateContent(content);
      String rawResponse = response.text ?? 'No response from AI';

      // ✅ Format response before displaying
      String formattedResponse = formatAIResponse(rawResponse);

      setState(() {
        _messages.add(
          MassegesEntities(massege: formattedResponse, isSender: false),
        );
        _listKey.currentState?.insertItem(_messages.length - 1);
        _isLoading = false;
        _selectedImage = null;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        shadowColor: Theme.of(context).appBarTheme.shadowColor,
        elevation: 3,
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AppImages.appBarLogo, height: 50, width: 50),
        ),
        title: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Chat Bot',
                style: GoogleFonts.nunito(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primaryColor,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  const Icon(Icons.circle, color: Colors.green, size: 10),
                  Text(
                    'Online',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Image.asset(
              AppImages.volume,
              height: 50,
              width: 50,
              color: AppColor.primaryColor,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Image.asset(
              AppImages.export,
              height: 50,
              width: 50,
              color: AppColor.primaryColor,
            ),
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: AppColor.primaryColor,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(children: [Expanded(child: _chatList()), _inputField()]),
      ),
    );
  }

  Widget _chatList() {
    var themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return AnimatedList(
      key: _listKey,
      initialItemCount: _messages.length,
      itemBuilder: (context, index, animation) {
        final message = _messages[index];
        final isSender = message.isSender;

        return FadeTransition(
          opacity: animation,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Align(
              alignment:
                  isSender ? Alignment.centerRight : Alignment.centerLeft,
              child: GestureDetector(
                onLongPress: () {
                  if (!isSender) {
                    Clipboard.setData(
                      ClipboardData(text: message.massege),
                    ); // ✅ Copy text to clipboard
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor:
                            isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        content: Center(
                          child: Text(
                            'Response copied to clipboard!',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient:
                        isSender
                            ? (isDarkMode
                                ? const LinearGradient(
                                  colors: [
                                    Color(0xFF0051A2),
                                    Color(0xFF003B7A),
                                  ],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                )
                                : const LinearGradient(
                                  colors: [
                                    Color(0xFF007AFF),
                                    Color(0xFF0051A2),
                                  ],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                ))
                            : (isDarkMode
                                ? const LinearGradient(
                                  colors: [
                                    Color(0xFF2C2C2E),
                                    Color(0xFF1C1C1E),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                                : const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 230, 230, 235),
                                    Color.fromARGB(255, 210, 210, 214),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )),
                    borderRadius:
                        isSender
                            ? const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            )
                            : const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isSender
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      if (message.image != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            message.image!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      if (message.massege.isNotEmpty)
                        Text(
                          message.massege,
                          style: GoogleFonts.nunito(
                            color:
                                isSender
                                    ? Colors.white
                                    : (isDarkMode
                                        ? Colors.white70
                                        : Colors.black87),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(DateTime.now()),
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color:
                              isSender
                                  ? Colors.white70
                                  : (isDarkMode
                                      ? Colors.white54
                                      : Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Format timestamp as '12:30 PM' or 'Yesterday'
  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    if (time.day == now.day) {
      return "${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}";
    } else {
      return "Yesterday";
    }
  }

  /// 🖊 Modified Input Field UI
  Widget _inputField() {
    var themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ Show Image Preview if an Image is Selected
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImage!,
                  width: 40, // ✅ Small preview size
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // ✅ Text Input Field
          Expanded(
            child: TextField(
              controller: _controller,
              cursorColor: Colors.blueAccent,
              decoration: InputDecoration(
                hintText:
                    _selectedImage != null
                        ? 'Image attached...'
                        : 'Write your message...',
                border: InputBorder.none,
              ),
            ),
          ),

          // 📎 Attach Image Button
          IconButton(
            icon: const Icon(Icons.attach_file, color: AppColor.primaryColor),
            onPressed: () => pickImage(ImageSource.gallery),
          ),

          // 📨 Send Button or Loading Indicator
          _isLoading
              ? const SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.primaryColor,
                ),
              )
              : GestureDetector(
                onTap: callGeminiModel,
                child: Image.asset(AppImages.send, height: 25, width: 25),
              ),
        ],
      ),
    );
  }
}
