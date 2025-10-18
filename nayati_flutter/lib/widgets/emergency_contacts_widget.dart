import 'package:flutter/material.dart';
import '../models/emergency_contact.dart' as model;
import '../services/emergency_contacts_database.dart';
import '../services/emergency_service.dart';
import '../theme/app_theme.dart';
import '../utils/logger_util.dart';

class EmergencyContactsWidget extends StatefulWidget {
  const EmergencyContactsWidget({super.key});

  @override
  State<EmergencyContactsWidget> createState() => _EmergencyContactsWidgetState();
}

class _EmergencyContactsWidgetState extends State<EmergencyContactsWidget> {
  final EmergencyContactsDatabase _database = EmergencyContactsDatabase();
  List<model.EmergencyContact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final contacts = await _database.getAllEmergencyContacts();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading emergency contacts: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load emergency contacts');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _addContact() async {
    try {
      final result = await _showContactDialog();
      if (result != null) {
        await _database.insertEmergencyContact(result);
        await _loadContacts();
        _showSuccessSnackBar('Emergency contact added successfully');
      }
    } catch (e) {
      AppLogger.error('Error adding emergency contact: $e');
      _showErrorSnackBar('Failed to add emergency contact');
    }
  }

  Future<void> _editContact(model.EmergencyContact contact) async {
    final result = await _showContactDialog(contact: contact);
    if (result != null) {
      try {
        await _database.updateEmergencyContact(result);
        await _loadContacts();
        _showSuccessSnackBar('Emergency contact updated successfully');
      } catch (e) {
        AppLogger.error('Error updating emergency contact: $e');
        _showErrorSnackBar('Failed to update emergency contact');
      }
    }
  }

  Future<void> _deleteContact(model.EmergencyContact contact) async {
    final confirmed = await _showDeleteConfirmation(contact);
    if (confirmed) {
      try {
        await _database.deleteEmergencyContact(contact.id!);
        await _loadContacts();
        _showSuccessSnackBar('Emergency contact deleted successfully');
      } catch (e) {
        AppLogger.error('Error deleting emergency contact: $e');
        _showErrorSnackBar('Failed to delete emergency contact');
      }
    }
  }

  Future<void> _setPrimaryContact(model.EmergencyContact contact) async {
    try {
      await _database.setPrimaryEmergencyContact(contact.id!);
      await _loadContacts();
      _showSuccessSnackBar('${contact.name} set as primary emergency contact');
    } catch (e) {
      AppLogger.error('Error setting primary contact: $e');
      _showErrorSnackBar('Failed to set primary contact');
    }
  }

  Future<void> _handleFormSubmission(
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController phoneController,
    TextEditingController relationshipController,
    ValueNotifier<bool> isPrimaryController,
    model.EmergencyContact? contact,
    EmergencyContactsDatabase database, {
    VoidCallback? onDispose,
  }) async {
    if (formKey.currentState!.validate()) {
      try {
        // Check for duplicate phone number
        final phoneExists = await database.phoneNumberExists(
          phoneController.text.trim(),
          excludeId: contact?.id,
        );
        
        if (phoneExists) {
          _showErrorSnackBar('This phone number is already in use');
          return;
        }

        final now = DateTime.now();
        final newContact = model.EmergencyContact(
          id: contact?.id,
          name: nameController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          relationship: relationshipController.text.trim().isEmpty 
              ? null 
              : relationshipController.text.trim(),
          isPrimary: isPrimaryController.value,
          createdAt: contact?.createdAt ?? now,
          updatedAt: now,
        );

        // Close dialog and return the contact
        onDispose?.call();
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(newContact);
        }
      } catch (e) {
        AppLogger.error('Error in form submission: $e');
        _showErrorSnackBar('An error occurred while processing the form');
      }
    }
  }

  Future<model.EmergencyContact?> _showContactDialog({model.EmergencyContact? contact}) async {
    final nameController = TextEditingController(text: contact?.name ?? '');
    final phoneController = TextEditingController(text: contact?.phoneNumber ?? '');
    final relationshipController = TextEditingController(text: contact?.relationship ?? '');
    final isPrimaryController = ValueNotifier<bool>(contact?.isPrimary ?? false);

    final formKey = GlobalKey<FormState>();

    // Ensure controllers are disposed when dialog closes
    void disposeControllers() {
      nameController.dispose();
      phoneController.dispose();
      relationshipController.dispose();
      isPrimaryController.dispose();
    }

    return showDialog<model.EmergencyContact>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (dialogContext) => AlertDialog(
        title: Text(contact == null ? 'Add Emergency Contact' : 'Edit Emergency Contact'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter contact name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (!model.EmergencyContact.isValidPhoneNumber(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: relationshipController,
                decoration: const InputDecoration(
                  labelText: 'Relationship (Optional)',
                  hintText: 'e.g., Spouse, Parent, Friend',
                  prefixIcon: Icon(Icons.family_restroom),
                ),
              ),
              const SizedBox(height: 16),
              if (contact == null || !contact.isPrimary)
                ValueListenableBuilder<bool>(
                  valueListenable: isPrimaryController,
                  builder: (context, isPrimary, child) => CheckboxListTile(
                    title: const Text('Set as Primary Contact'),
                    subtitle: const Text('Primary contact will be called first during emergencies'),
                    value: isPrimary,
                    onChanged: (value) {
                      isPrimaryController.value = value ?? false;
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              disposeControllers();
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _handleFormSubmission(
                  formKey,
                  nameController,
                  phoneController,
                  relationshipController,
                  isPrimaryController,
                  contact,
                  _database,
                  onDispose: disposeControllers,
                );
              } catch (e) {
                AppLogger.error('Error in dialog form submission: $e');
                disposeControllers();
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
                _showErrorSnackBar('Failed to process form');
              }
            },
            child: Text(contact == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(model.EmergencyContact contact) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Emergency Contact'),
        content: Text('Are you sure you want to delete ${contact.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.emergency,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _addContact,
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Emergency Contact',
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your emergency contacts. These contacts will be available during emergency situations.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_contacts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.contacts_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Emergency Contacts',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add emergency contacts to get help quickly',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _contacts.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: contact.isPrimary 
                          ? AppTheme.primaryColor 
                          : Colors.grey[300],
                      child: Icon(
                        contact.isPrimary ? Icons.star : Icons.person,
                        color: contact.isPrimary ? Colors.white : Colors.grey[600],
                      ),
                    ),
                    title: Text(
                      contact.displayName,
                      style: TextStyle(
                        fontWeight: contact.isPrimary ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contact.formattedPhoneNumber),
                        if (contact.isPrimary)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
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
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        switch (value) {
                          case 'call':
                            await _callContact(contact);
                            break;
                          case 'set_primary':
                            await _setPrimaryContact(contact);
                            break;
                          case 'edit':
                            await _editContact(contact);
                            break;
                          case 'delete':
                            await _deleteContact(contact);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'call',
                          child: ListTile(
                            leading: Icon(Icons.phone),
                            title: Text('Call'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        if (!contact.isPrimary)
                          const PopupMenuItem(
                            value: 'set_primary',
                            child: ListTile(
                              leading: Icon(Icons.star),
                              title: Text('Set as Primary'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Delete', style: TextStyle(color: Colors.red)),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _callContact(contact),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _callContact(model.EmergencyContact contact) async {
    try {
      _showSuccessSnackBar('Sending location SMS and calling ${contact.name}...');
      
      final success = await EmergencyService.callEmergencyContact(contact);
      
      if (success) {
        _showSuccessSnackBar('Call to ${contact.name} initiated successfully. Location SMS sent.');
      } else {
        _showErrorSnackBar('Failed to call ${contact.name}');
      }
    } catch (e) {
      AppLogger.error('Error calling contact: $e');
      _showErrorSnackBar('Failed to call ${contact.name}');
    }
  }
}
