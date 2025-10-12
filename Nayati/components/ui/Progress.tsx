import React from 'react';
import { View, Text, StyleSheet, ViewStyle } from 'react-native';

interface ProgressProps {
  value: number; // 0-100
  max?: number;
  size?: 'default' | 'sm' | 'lg';
  variant?: 'default' | 'success' | 'warning' | 'destructive';
  showValue?: boolean;
  style?: ViewStyle;
}

export function Progress({
  value,
  max = 100,
  size = 'default',
  variant = 'default',
  showValue = false,
  style,
}: ProgressProps) {
  const percentage = Math.min(Math.max((value / max) * 100, 0), 100);

  const progressStyle = [
    styles.base,
    styles[size],
    style,
  ];

  const fillStyle = [
    styles.fill,
    styles[`${variant}Fill`],
    { width: `${percentage}%` },
  ];

  return (
    <View style={progressStyle}>
      <View style={styles.track}>
        <View style={fillStyle} />
      </View>
      {showValue && (
        <Text style={[styles.valueText, styles[`${size}Text`]]}>
          {Math.round(percentage)}%
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  base: {
    gap: 8,
  },
  track: {
    height: 8,
    backgroundColor: '#E5E7EB',
    borderRadius: 4,
    overflow: 'hidden',
  },
  fill: {
    height: '100%',
    borderRadius: 4,
  },
  // Variants
  defaultFill: {
    backgroundColor: '#2563EB',
  },
  successFill: {
    backgroundColor: '#16A34A',
  },
  warningFill: {
    backgroundColor: '#F59E0B',
  },
  destructiveFill: {
    backgroundColor: '#DC2626',
  },
  // Sizes
  default: {
    height: 8,
  },
  sm: {
    height: 4,
  },
  lg: {
    height: 12,
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
  valueText: {
    color: '#6B7280',
    fontWeight: '500',
    textAlign: 'center',
  },
});
