# A11yPal Mobile App

A React Native Expo app for accessibility assistance with visual, hearing, and mobility support features.

## Features

- **Visual Assist**: Object detection, text reading, and navigation guidance
- **Hearing Assist**: Live transcription, sound alerts, and visual notifications  
- **Mobility Assist**: Accessible routes, indoor navigation, and mobility guidance
- **Interactive Map**: Building map with search and navigation
- **History**: Track usage and access previous sessions
- **Settings**: Customize accessibility preferences

## Getting Started

### Prerequisites

- Node.js (v16 or later)
- npm or yarn
- Expo CLI
- iOS Simulator (for iOS development) or Android Studio (for Android development)

### Installation

1. Navigate to the Nayati directory:
   ```bash
   cd Nayati
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm start
   ```

4. Run on your preferred platform:
   - **iOS**: Press `i` in the terminal or scan QR code with Expo Go app
   - **Android**: Press `a` in the terminal or scan QR code with Expo Go app
   - **Web**: Press `w` in the terminal

## App Structure

```
Nayati/
├── app/                    # Expo Router pages
│   ├── (tabs)/            # Tab navigation screens
│   │   ├── index.tsx      # Main home screen
│   │   ├── history.tsx    # History tab
│   │   ├── map.tsx        # Map tab
│   │   └── settings.tsx   # Settings tab
│   └── _layout.tsx        # Root layout
├── components/            # React Native components
│   ├── ui/               # Reusable UI components
│   ├── figma/            # Figma-specific components
│   └── [Screen].tsx      # Main screen components
├── contexts/             # React contexts
│   └── NavigationContext.tsx
├── types/                # TypeScript type definitions
│   └── navigation.ts
└── App.tsx              # Main app component
```

## Navigation

The app uses a custom navigation context that manages screen state. Each screen can navigate to other screens using the `onNavigate` prop.

### Available Screens

- `home` - Main landing page
- `visual` - Visual assistance features
- `hearing` - Hearing assistance features  
- `mobility` - Mobility assistance features
- `map` - Interactive building map
- `history` - Usage history
- `settings` - App settings

## Development

### Adding New Screens

1. Create a new component in `components/`
2. Add the screen type to `types/navigation.ts`
3. Update the navigation context and main screen renderer
4. Add any necessary tab navigation

### Styling

The app uses React Native's StyleSheet for styling. All components follow a consistent design system with:

- Primary colors: Blue (#2563EB), Orange (#EA580C), Green (#16A34A)
- Typography: System fonts with consistent sizing
- Spacing: 8px base unit
- Border radius: 8px, 12px, 16px variants

## Accessibility

The app is designed with accessibility in mind:

- High contrast mode support
- Large text options
- Voice announcements
- Haptic feedback
- Screen reader compatibility
- Keyboard navigation support

## License

This project is part of the A11yPal accessibility platform.