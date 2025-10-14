import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/indoor_navigation_provider.dart';
import '../theme/app_theme.dart';

class IndoorNavigationScreen extends StatefulWidget {
  const IndoorNavigationScreen({super.key});

  @override
  State<IndoorNavigationScreen> createState() => _IndoorNavigationScreenState();
}

class _IndoorNavigationScreenState extends State<IndoorNavigationScreen> {
  String? _selectedBuilding;
  String? _selectedFloor;
  String? _selectedStartRoom;
  String? _selectedEndRoom;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IndoorNavigationProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Indoor Navigation'),
        backgroundColor: AppTheme.mobilityAssistColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<IndoorNavigationProvider>(
            builder: (context, provider, child) {
              if (provider.isNavigating) {
                return IconButton(
                  icon: Icon(provider.isSpeaking ? Icons.volume_off : Icons.volume_up),
                  onPressed: () => provider.toggleVoiceGuidance(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<IndoorNavigationProvider>(
        builder: (context, provider, child) {
          if (provider.isNavigating) {
            return _buildActiveNavigation(provider);
          } else {
            return _buildNavigationSetup(provider);
          }
        },
      ),
    );
  }

  Widget _buildActiveNavigation(IndoorNavigationProvider provider) {
    return Column(
      children: [
        _buildNavigationHeader(provider),
        Expanded(
          child: _buildNavigationSteps(provider),
        ),
        _buildNavigationControls(provider),
      ],
    );
  }

  Widget _buildNavigationHeader(IndoorNavigationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.mobilityAssistColor.withValues(alpha: 0.1),
        border: const Border(
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Navigating to ${provider.destinationRoom}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.currentBuilding} - ${provider.currentFloor}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.mobilityAssistColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(provider.progressPercentage * 100).toInt()}% Complete',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: provider.progressPercentage,
            backgroundColor: AppTheme.borderColor,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.mobilityAssistColor),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSteps(IndoorNavigationProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: provider.navigationSteps.length,
      itemBuilder: (context, index) {
        final step = provider.navigationSteps[index];
        final isCurrentStep = index == provider.currentStepIndex;
        final isCompleted = index < provider.currentStepIndex;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.mobilityAssistColor
                      : isCurrentStep
                          ? AppTheme.mobilityAssistColor
                          : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrentStep
                        ? AppTheme.mobilityAssistColor
                        : AppTheme.borderColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrentStep ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['instruction'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isCurrentStep ? FontWeight.w600 : FontWeight.w400,
                        color: isCurrentStep ? AppTheme.mobilityAssistColor : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          step['distance'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          step['icon'],
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          step['roomName'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (step['accessible'] == true) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.accessible,
                            size: 16,
                            color: AppTheme.mobilityAssistColor,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (isCurrentStep)
                const Icon(
                  Icons.arrow_forward,
                  color: AppTheme.mobilityAssistColor,
                  size: 20,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationControls(IndoorNavigationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: provider.currentStepIndex > 0 ? () => provider.previousStep() : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.mobilityAssistColor,
                side: const BorderSide(color: AppTheme.mobilityAssistColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => provider.nextStep(),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.mobilityAssistColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => provider.speakCurrentInstruction(),
            icon: const Icon(Icons.volume_up),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.mobilityAssistColor.withValues(alpha: 0.1),
              foregroundColor: AppTheme.mobilityAssistColor,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => provider.stopNavigation(),
            icon: const Icon(Icons.stop),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSetup(IndoorNavigationProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBuildingSelection(provider),
          const SizedBox(height: 24),
          if (_selectedBuilding != null) _buildFloorSelection(provider),
          const SizedBox(height: 24),
          if (_selectedFloor != null) _buildRoomSelection(provider),
          const SizedBox(height: 24),
          if (_selectedStartRoom != null && _selectedEndRoom != null)
            _buildStartNavigationButton(provider),
          if (provider.errorMessage.isNotEmpty)
            _buildErrorMessage(provider),
        ],
      ),
    );
  }

  Widget _buildBuildingSelection(IndoorNavigationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Building',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...provider.availableBuildings.map((buildingId) {
          final building = provider.getBuildingDetails(buildingId);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: _selectedBuilding == buildingId
                  ? AppTheme.mobilityAssistColor.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedBuilding = buildingId;
                    _selectedFloor = null;
                    _selectedStartRoom = null;
                    _selectedEndRoom = null;
                  });
                  provider.loadBuilding(buildingId);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedBuilding == buildingId
                          ? AppTheme.mobilityAssistColor
                          : AppTheme.borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.business,
                        color: _selectedBuilding == buildingId
                            ? AppTheme.mobilityAssistColor
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          building?['name'] ?? buildingId,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _selectedBuilding == buildingId
                                ? AppTheme.mobilityAssistColor
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (_selectedBuilding == buildingId)
                        const Icon(
                          Icons.check_circle,
                          color: AppTheme.mobilityAssistColor,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFloorSelection(IndoorNavigationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Floor',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...provider.availableFloors.map((floorId) {
          final floor = provider.getFloorRooms(_selectedBuilding!, floorId);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: _selectedFloor == floorId
                  ? AppTheme.mobilityAssistColor.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedFloor = floorId;
                    _selectedStartRoom = null;
                    _selectedEndRoom = null;
                  });
                  provider.loadFloor(floorId);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedFloor == floorId
                          ? AppTheme.mobilityAssistColor
                          : AppTheme.borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.layers,
                        color: _selectedFloor == floorId
                            ? AppTheme.mobilityAssistColor
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          floor?['name'] ?? floorId,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _selectedFloor == floorId
                                ? AppTheme.mobilityAssistColor
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (_selectedFloor == floorId)
                        const Icon(
                          Icons.check_circle,
                          color: AppTheme.mobilityAssistColor,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRoomSelection(IndoorNavigationProvider provider) {
    final rooms = provider.floorRooms;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Rooms',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search rooms...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Start Room',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...rooms.entries
                      .where((entry) => entry.value['name']
                          .toString()
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase()))
                      .map((entry) {
                    final roomId = entry.key;
                    final room = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: _selectedStartRoom == roomId
                            ? AppTheme.mobilityAssistColor.withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedStartRoom = roomId;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _selectedStartRoom == roomId
                                    ? AppTheme.mobilityAssistColor
                                    : AppTheme.borderColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getIconForRoomType(room['type']),
                                  size: 16,
                                  color: _selectedStartRoom == roomId
                                      ? AppTheme.mobilityAssistColor
                                      : AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    room['name'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _selectedStartRoom == roomId
                                          ? AppTheme.mobilityAssistColor
                                          : AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Destination Room',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...rooms.entries
                      .where((entry) => entry.value['name']
                          .toString()
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase()))
                      .map((entry) {
                    final roomId = entry.key;
                    final room = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: _selectedEndRoom == roomId
                            ? AppTheme.mobilityAssistColor.withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedEndRoom = roomId;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _selectedEndRoom == roomId
                                    ? AppTheme.mobilityAssistColor
                                    : AppTheme.borderColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getIconForRoomType(room['type']),
                                  size: 16,
                                  color: _selectedEndRoom == roomId
                                      ? AppTheme.mobilityAssistColor
                                      : AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    room['name'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _selectedEndRoom == roomId
                                          ? AppTheme.mobilityAssistColor
                                          : AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStartNavigationButton(IndoorNavigationProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          provider.startNavigation(
            startRoom: _selectedStartRoom!,
            endRoom: _selectedEndRoom!,
          );
        },
        icon: const Icon(Icons.navigation),
        label: const Text('Start Navigation'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.mobilityAssistColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(IndoorNavigationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.errorMessage,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            onPressed: () => provider.clearError(),
            icon: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    );
  }

  IconData _getIconForRoomType(String type) {
    switch (type) {
      case 'entrance':
        return Icons.door_front_door;
      case 'elevator':
        return Icons.elevator;
      case 'escalator':
        return Icons.stairs;
      case 'restroom':
        return Icons.wc;
      case 'service':
        return Icons.help_outline;
      case 'dining':
        return Icons.restaurant;
      case 'classroom':
        return Icons.school;
      case 'office':
        return Icons.work;
      case 'lab':
        return Icons.science;
      case 'ward':
        return Icons.local_hospital;
      case 'retail':
        return Icons.store;
      case 'meeting':
        return Icons.meeting_room;
      case 'study':
        return Icons.menu_book;
      default:
        return Icons.room;
    }
  }
}
