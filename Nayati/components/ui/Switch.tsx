import React from 'react';
import { Switch as RNSwitch, StyleSheet } from 'react-native';

interface SwitchProps {
  value: boolean;
  onValueChange: (value: boolean) => void;
  disabled?: boolean;
  trackColor?: { false: string; true: string };
  thumbColor?: string;
}

export function Switch({
  value,
  onValueChange,
  disabled = false,
  trackColor = { false: '#E5E7EB', true: '#2563EB' },
  thumbColor = '#FFFFFF',
}: SwitchProps) {
  return (
    <RNSwitch
      value={value}
      onValueChange={onValueChange}
      disabled={disabled}
      trackColor={trackColor}
      thumbColor={thumbColor}
      style={styles.switch}
    />
  );
}

const styles = StyleSheet.create({
  switch: {
    transform: [{ scaleX: 1.1 }, { scaleY: 1.1 }],
  },
});
