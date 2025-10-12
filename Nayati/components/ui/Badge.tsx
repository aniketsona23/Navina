import React from 'react';
import { View, Text, StyleSheet, ViewStyle, TextStyle } from 'react-native';

interface BadgeProps {
  children: React.ReactNode;
  variant?: 'default' | 'secondary' | 'destructive' | 'outline';
  size?: 'default' | 'sm' | 'lg';
  style?: ViewStyle;
  textStyle?: TextStyle;
}

export function Badge({
  children,
  variant = 'default',
  size = 'default',
  style,
  textStyle,
}: BadgeProps) {
  const badgeStyle = [
    styles.base,
    styles[variant],
    styles[size],
    style,
  ];

  const textStyleCombined = [
    styles.text,
    styles[`${variant}Text`],
    styles[`${size}Text`],
    textStyle,
  ];

  return (
    <View style={badgeStyle}>
      <Text style={textStyleCombined}>{children}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  base: {
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 12,
  },
  // Variants
  default: {
    backgroundColor: '#2563EB',
  },
  secondary: {
    backgroundColor: '#F3F4F6',
  },
  destructive: {
    backgroundColor: '#DC2626',
  },
  outline: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  // Sizes
  default: {
    paddingHorizontal: 8,
    paddingVertical: 4,
  },
  sm: {
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 8,
  },
  lg: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
  },
  // Text styles
  text: {
    fontWeight: '500',
  },
  defaultText: {
    color: '#FFFFFF',
  },
  secondaryText: {
    color: '#000000',
  },
  destructiveText: {
    color: '#FFFFFF',
  },
  outlineText: {
    color: '#000000',
  },
  // Size text styles
  defaultText: {
    fontSize: 12,
  },
  smText: {
    fontSize: 10,
  },
  lgText: {
    fontSize: 14,
  },
});
