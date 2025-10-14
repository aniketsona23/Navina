import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../models/emergency_contact.dart';
import '../services/emergency_contacts_database.dart';
import '../utils/logger_util.dart';

class EmergencyService {
  static const String _emergencyNumberKey = 'emergency_number';
  
  // Default emergency numbers by country (India as primary)
  static const Map<String, String> _defaultEmergencyNumbers = {
    'IN': '121', // Police (India)
    'US': '911',
    'CA': '911',
    'GB': '999',
    'AU': '000',
    'DE': '112',
    'FR': '112',
    'JP': '110',
    'BR': '190',
    'MX': '911',
  };


  /// Get the primary emergency number
  static Future<String> getEmergencyNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNumber = prefs.getString(_emergencyNumberKey);
    
    if (savedNumber != null && savedNumber.isNotEmpty) {
      return savedNumber;
    }
    
    // Try to detect country and use default
    final countryCode = Platform.localeName.split('_').last;
    return _defaultEmergencyNumbers[countryCode] ?? '100';
  }

  /// Set custom emergency number
  static Future<void> setEmergencyNumber(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emergencyNumberKey, number);
  }


  /// Call emergency number directly
  static Future<bool> callEmergency() async {
    try {
      final emergencyNumber = await getEmergencyNumber();
      EmergencyLogger.info('Calling emergency number directly: $emergencyNumber');
      
      // Use direct caller to make the call
      final result = await FlutterPhoneDirectCaller.callNumber(emergencyNumber);
      
      if (result == true) {
        EmergencyLogger.info('Emergency call initiated successfully');
        
        // Provide haptic feedback
        await HapticFeedback.heavyImpact();
        
        return true;
      } else {
        EmergencyLogger.error('Failed to initiate emergency call: $emergencyNumber');
        return false;
      }
    } catch (e) {
      EmergencyLogger.error('Emergency call failed: $e');
      return false;
    }
  }

  /// Get current user location
  static Future<LocationInfo?> getCurrentLocation() async {
    try {
      EmergencyLogger.info('Getting current location for emergency SMS');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        EmergencyLogger.warning('Location services are disabled');
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          EmergencyLogger.warning('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        EmergencyLogger.warning('Location permissions are permanently denied');
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      EmergencyLogger.info('Location obtained: ${position.latitude}, ${position.longitude}');

      // Try to get address from coordinates
      String address = 'Unknown Location';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          address = _formatAddress(place);
        }
      } catch (e) {
        EmergencyLogger.warning('Failed to get address: $e');
      }

      return LocationInfo(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        address: address,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      EmergencyLogger.error('Failed to get location: $e');
      return null;
    }
  }

  /// Format address from placemark
  static String _formatAddress(Placemark place) {
    List<String> addressParts = [];
    
    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      addressParts.add(place.country!);
    }
    
    return addressParts.isNotEmpty ? addressParts.join(', ') : 'Unknown Address';
  }

  /// Send emergency SMS with location (opens SMS app with pre-filled message)
  static Future<bool> sendEmergencySMSWithLocation([String? customMessage]) async {
    try {
      final emergencyNumber = await getEmergencyNumber();
      EmergencyLogger.info('Opening SMS app with location message for: $emergencyNumber');
      
      // Get current location
      final locationInfo = await getCurrentLocation();
      
      // Create emergency message
      String message = customMessage ?? _createEmergencyMessage(locationInfo);
      
      // Create SMS URI with pre-filled message
      final uri = Uri(
        scheme: 'sms',
        path: emergencyNumber,
        queryParameters: {'body': message},
      );
      
      // Check if SMS app can be launched
      final canLaunch = await canLaunchUrl(uri);
      
      if (canLaunch) {
        // Launch SMS app with pre-filled message
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        EmergencyLogger.info('SMS app opened with location message');
        
        // Provide haptic feedback
        await HapticFeedback.mediumImpact();
        
        return true;
      } else {
        EmergencyLogger.error('Cannot launch SMS app for: $emergencyNumber');
        return false;
      }
    } catch (e) {
      EmergencyLogger.error('Emergency SMS with location failed: $e');
      return false;
    }
  }

  /// Send emergency SMS (legacy method for backward compatibility)
  static Future<bool> sendEmergencySMS(String message) async {
    return sendEmergencySMSWithLocation(message);
  }

  /// Create formatted emergency message with location
  static String _createEmergencyMessage(LocationInfo? locationInfo) {
    StringBuffer message = StringBuffer();
    
    message.writeln('🚨 EMERGENCY SOS 🚨');
    message.writeln('I need help immediately!');
    message.writeln('');
    
    if (locationInfo != null) {
      message.writeln('📍 MY LOCATION:');
      message.writeln(locationInfo.address);
      message.writeln('');
      message.writeln('Coordinates:');
      message.writeln('Latitude: ${locationInfo.latitude.toStringAsFixed(6)}');
      message.writeln('Longitude: ${locationInfo.longitude.toStringAsFixed(6)}');
      message.writeln('Accuracy: ${locationInfo.accuracy.toStringAsFixed(0)}m');
      message.writeln('');
      message.writeln('Time: ${locationInfo.timestamp.toLocal()}');
      message.writeln('');
    } else {
      message.writeln('⚠️ Location not available');
      message.writeln('');
    }
    
    message.writeln('Please send help immediately!');
    message.writeln('');
    message.writeln('Sent from Nayati Accessibility App');
    
    return message.toString();
  }

  /// Call specific emergency contact directly and send SMS with location
  static Future<bool> callEmergencyContact(EmergencyContact contact) async {
    try {
      final dialableNumber = contact.dialablePhoneNumber;
      EmergencyLogger.info('Calling emergency contact directly: ${contact.name} - $dialableNumber');
      
      // First, send SMS with location
      await _sendSMSToContactWithLocation(contact);
      
      // Then initiate the call directly
      final result = await FlutterPhoneDirectCaller.callNumber(dialableNumber);
      
      if (result == true) {
        EmergencyLogger.info('Emergency contact call initiated successfully');
        
        // Provide haptic feedback
        await HapticFeedback.heavyImpact();
        
        return true;
      } else {
        EmergencyLogger.error('Failed to initiate emergency contact call: $dialableNumber');
        return false;
      }
    } catch (e) {
      EmergencyLogger.error('Emergency contact call failed: $e');
      return false;
    }
  }

  /// Send SMS to contact with location (opens SMS app with pre-filled message)
  static Future<void> _sendSMSToContactWithLocation(EmergencyContact contact) async {
    try {
      EmergencyLogger.info('Opening SMS app with location message for emergency contact: ${contact.name}');
      
      // Get current location
      final locationInfo = await getCurrentLocation();
      
      // Create emergency message
      String message = _createEmergencyMessage(locationInfo);
      
      // Create SMS URI with pre-filled message
      final uri = Uri(
        scheme: 'sms',
        path: contact.dialablePhoneNumber,
        queryParameters: {'body': message},
      );
      
      // Check if SMS app can be launched
      final canLaunch = await canLaunchUrl(uri);
      
      if (canLaunch) {
        // Launch SMS app with pre-filled message
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        EmergencyLogger.info('SMS app opened with location message for emergency contact');
      } else {
        EmergencyLogger.warning('Cannot launch SMS app for emergency contact: ${contact.dialablePhoneNumber}');
      }
    } catch (e) {
      EmergencyLogger.warning('Failed to open SMS app for emergency contact: $e');
      // Don't throw error, as call should still proceed even if SMS fails
    }
  }

  /// Get all emergency contacts from database
  static Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      final database = EmergencyContactsDatabase();
      final contacts = await database.getAllEmergencyContacts();
      EmergencyLogger.info('Retrieved ${contacts.length} emergency contacts from database');
      return contacts;
    } catch (e) {
      EmergencyLogger.error('Error retrieving emergency contacts from database: $e');
      return [];
    }
  }

  /// Get primary emergency contact from database
  static Future<EmergencyContact?> getPrimaryEmergencyContact() async {
    try {
      final database = EmergencyContactsDatabase();
      final contact = await database.getPrimaryEmergencyContact();
      if (contact != null) {
        EmergencyLogger.info('Retrieved primary emergency contact: ${contact.name}');
      } else {
        EmergencyLogger.info('No primary emergency contact found in database');
      }
      return contact;
    } catch (e) {
      EmergencyLogger.error('Error retrieving primary emergency contact from database: $e');
      return null;
    }
  }

  /// Send SMS to specific emergency contact with location
  static Future<bool> sendSMSToEmergencyContact(EmergencyContact contact, [String? customMessage]) async {
    try {
      EmergencyLogger.info('Sending emergency SMS to contact: ${contact.name} - ${contact.phoneNumber}');
      
      // Get current location
      final locationInfo = await getCurrentLocation();
      
      // Create emergency message
      String message = customMessage ?? _createEmergencyMessage(locationInfo);
      
      final uri = Uri(
        scheme: 'sms',
        path: contact.phoneNumber,
        queryParameters: {'body': message},
      );
      
      final canLaunch = await canLaunchUrl(uri);
      
      if (canLaunch) {
        await launchUrl(uri);
        EmergencyLogger.info('Emergency SMS to contact initiated successfully');
        
        // Provide haptic feedback
        await HapticFeedback.mediumImpact();
        
        return true;
      } else {
        EmergencyLogger.error('Cannot launch SMS to ${contact.phoneNumber}');
        return false;
      }
    } catch (e) {
      EmergencyLogger.error('Emergency SMS to contact failed: $e');
      return false;
    }
  }

  /// Get emergency actions menu
  static List<EmergencyAction> getEmergencyActions() {
    return [
      EmergencyAction(
        title: 'Call Emergency Services',
        subtitle: 'Call local emergency number',
        icon: '📞',
        action: EmergencyActionType.call,
      ),
      EmergencyAction(
        title: 'Send Emergency SMS',
        subtitle: 'Send location and SOS message',
        icon: '💬',
        action: EmergencyActionType.smsWithLocation,
      ),
      EmergencyAction(
        title: 'Emergency Contacts',
        subtitle: 'Call saved emergency contacts',
        icon: '👥',
        action: EmergencyActionType.contacts,
      ),
    ];
  }

  /// Show emergency contacts dialog (static method for use across widgets)
  static Future<void> showEmergencyContactsDialog(BuildContext context) async {
    try {
      // Get emergency contacts from database
      final contacts = await getEmergencyContacts();
      
      if (contacts.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No emergency contacts found. Add contacts in Settings.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Show contacts selection dialog
      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildEmergencyContactsDialog(context, contacts),
        );
      }
    } catch (e) {
      EmergencyLogger.error('Error showing emergency contacts: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load emergency contacts'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Build emergency contacts dialog (static method)
  static Widget _buildEmergencyContactsDialog(BuildContext context, List<EmergencyContact> contacts) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.contacts,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a contact to call',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: contact.isPrimary 
                          ? Colors.red.withValues(alpha: 0.2)
                          : Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        color: contact.isPrimary ? Colors.red : Colors.blue,
                        size: 24,
                      ),
                    ),
                  ),
                  title: Text(
                    contact.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.formattedPhoneNumber,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (contact.isPrimary)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'PRIMARY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.phone,
                    color: Colors.green,
                    size: 24,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _callEmergencyContactFromDialog(context, contact);
                  },
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Call emergency contact from dialog (static method)
  static Future<void> _callEmergencyContactFromDialog(BuildContext context, EmergencyContact contact) async {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sending location SMS and calling ${contact.name}...'),
            backgroundColor: Colors.blue,
          ),
        );
      }
      
      final success = await callEmergencyContact(contact);
      
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Call to ${contact.name} initiated successfully. Location SMS sent.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to call ${contact.name}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      EmergencyLogger.error('Error calling emergency contact: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to call ${contact.name}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}


class EmergencyAction {
  final String title;
  final String subtitle;
  final String icon;
  final EmergencyActionType action;

  EmergencyAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.action,
  });
}

enum EmergencyActionType {
  call,
  sms,
  smsWithLocation,
  contacts,
}

class LocationInfo {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String address;
  final DateTime timestamp;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.address,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'LocationInfo(lat: $latitude, lng: $longitude, accuracy: ${accuracy}m, address: $address)';
  }
}

class EmergencyLogger {
  static void info(String message) {
    AppLogger.info('🆘 EMERGENCY: $message');
  }

  static void error(String message) {
    AppLogger.error('🆘 EMERGENCY ERROR: $message');
  }

  static void warning(String message) {
    AppLogger.warning('🆘 EMERGENCY WARNING: $message');
  }
}
