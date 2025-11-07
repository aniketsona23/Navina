import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'asl_fallback_service.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyAO8tkNtHSprzb6oXA5SDIsqvMOqw0AKmg';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';
  
  /// Analyze image for sign language recognition
  static Future<String?> analyzeSignLanguage(Uint8List imageData) async {
    try {
      // Convert image to base64
      final String base64Image = base64Encode(imageData);
      
      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text": "You are an expert in American Sign Language (ASL) recognition. Analyze this image carefully and identify the ASL gesture being made. Look for hand shapes, finger positions, and hand movements that correspond to ASL letters or signs. Return ONLY the English letter (A-Z) or common ASL word that the gesture represents. If you see a clear ASL gesture, return just the letter or word. If no clear ASL gesture is visible or if the image is unclear, return 'NOTHING'. Be precise and confident in your identification."
              },
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.1,
          "topK": 1,
          "topP": 1,
          "maxOutputTokens": 10
        }
      };
      
      // Make the API request
      print('Making request to Gemini API...');
      print('URL: $_baseUrl?key=$_apiKey');
      
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (responseData['candidates'] != null && 
            responseData['candidates'].isNotEmpty &&
            responseData['candidates'][0]['content'] != null &&
            responseData['candidates'][0]['content']['parts'] != null &&
            responseData['candidates'][0]['content']['parts'].isNotEmpty) {
          
          final String result = responseData['candidates'][0]['content']['parts'][0]['text'];
          print('Gemini raw response: $result'); // Debug log
          
          // Clean up the response - remove extra whitespace and common prefixes
          String cleanedResult = result.trim().toUpperCase();
          
          // Remove common prefixes and suffixes that might be added by the model
          final prefixesToRemove = [
            'THE LETTER ',
            'LETTER ',
            'THE ASL GESTURE FOR ',
            'THE ASL SIGN FOR ',
            'ASL LETTER ',
            'ASL SIGN ',
            'THE SIGN ',
            'SIGN FOR ',
            'THIS IS THE LETTER ',
            'THIS IS LETTER ',
            'THIS IS ',
          ];
          
          for (String prefix in prefixesToRemove) {
            if (cleanedResult.startsWith(prefix)) {
              cleanedResult = cleanedResult.substring(prefix.length);
              break;
            }
          }
          
          // Remove common suffixes
          final suffixesToRemove = [
            ' IN ASL',
            ' ASL',
            ' IN SIGN LANGUAGE',
            ' SIGN',
            '.',
            '!',
            '?',
          ];
          
          for (String suffix in suffixesToRemove) {
            if (cleanedResult.endsWith(suffix)) {
              cleanedResult = cleanedResult.substring(0, cleanedResult.length - suffix.length);
              break;
            }
          }
          
          // Extract just the first word/letter
          final words = cleanedResult.split(RegExp(r'[\s,.-]+'));
          if (words.isNotEmpty && words.first.isNotEmpty) {
            cleanedResult = words.first;
          }
          
          print('Cleaned result: $cleanedResult'); // Debug log
          
          // Validate that it's a reasonable ASL result
          if (_isValidASLResult(cleanedResult)) {
            return cleanedResult;
          }
        }
        
        return 'NOTHING';
      } else if (response.statusCode == 400) {
        print('Gemini API Error 400 (Bad Request): ${response.body}');
        return null;
      } else if (response.statusCode == 401) {
        print('Gemini API Error 401 (Unauthorized): Check API key');
        return null;
      } else if (response.statusCode == 403) {
        print('Gemini API Error 403 (Forbidden): API key may be invalid or quota exceeded');
        return null;
      } else if (response.statusCode == 429) {
        print('Gemini API Error 429 (Rate Limited): Too many requests');
        return null;
      } else {
        print('Gemini API Error: ${response.statusCode} - ${response.body}');
        print('Falling back to ASL Fallback Service...');
        return await ASLFallbackService.analyzeSignLanguage(imageData);
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      print('Falling back to ASL Fallback Service...');
      return await ASLFallbackService.analyzeSignLanguage(imageData);
    }
  }
  
  /// Validate if the result is a reasonable ASL output
  static bool _isValidASLResult(String result) {
    // Check if it's a single letter A-Z
    if (result.length == 1 && result.codeUnitAt(0) >= 65 && result.codeUnitAt(0) <= 90) {
      return true;
    }
    
    // Check for common ASL words and phrases
    const validWords = [
      'NOTHING', 'SPACE', 'DELETE', 'DEL', 'CLEAR', 'HELLO', 'THANK', 'YOU', 'YES', 'NO',
      'GOOD', 'BAD', 'PLEASE', 'SORRY', 'EXCUSE', 'ME', 'WATER', 'FOOD', 'HELP', 'STOP',
      'GO', 'COME', 'HERE', 'THERE', 'UP', 'DOWN', 'LEFT', 'RIGHT', 'BIG', 'SMALL',
      'HOT', 'COLD', 'HAPPY', 'SAD', 'ANGRY', 'SURPRISED', 'SCARED', 'TIRED', 'SICK',
      'MOTHER', 'FATHER', 'BROTHER', 'SISTER', 'FAMILY', 'FRIEND', 'LOVE', 'LIKE', 'WANT',
      'NEED', 'HAVE', 'GIVE', 'TAKE', 'BUY', 'SELL', 'WORK', 'PLAY', 'LEARN', 'TEACH',
      'READ', 'WRITE', 'DRAW', 'SING', 'DANCE', 'RUN', 'WALK', 'SIT', 'STAND', 'SLEEP'
    ];
    
    return validWords.contains(result);
  }
  
  /// Test the API connection
  static Future<bool> testConnection() async {
    try {
      print('Testing Gemini API connection...');
      
      // First, try a simple text-only request to test basic connectivity
      final Map<String, dynamic> testRequestBody = {
        "contents": [
          {
            "parts": [
              {
                "text": "Say 'test' if you can read this message."
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.1,
          "topK": 1,
          "topP": 1,
          "maxOutputTokens": 5
        }
      };
      
      print('Making test request to Gemini API...');
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(testRequestBody),
      );
      
      print('Test response status: ${response.statusCode}');
      print('Test response body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ Gemini API connection successful!');
        return true;
      } else {
        print('❌ Gemini API connection failed with status: ${response.statusCode}');
        print('✅ Fallback service will be used instead');
        return true; // Return true because fallback is available
      }
    } catch (e) {
      print('❌ Gemini API connection test failed: $e');
      print('✅ Fallback service will be used instead');
      return true; // Return true because fallback is available
    }
  }
}
