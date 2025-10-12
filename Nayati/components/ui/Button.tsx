import React from 'react';
import { TouchableOpacity, Text, StyleSheet, ViewStyle, TextStyle } from 'react-native';

interface ButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'default' | 'destructive' | 'outline' | 'secondary' | 'ghost' | 'link';
  size?: 'default' | 'sm' | 'lg' | 'icon';
  disabled?: boolean;
  style?: ViewStyle;
  textStyle?: TextStyle;
  icon?: React.ReactNode;
}

export function Button({
  title,
  onPress,
  variant = 'default',
  size = 'default',
  disabled = false,
  style,
  textStyle,
  icon,
}: ButtonProps) {
  const buttonStyle = [
    styles.base,
    styles[variant],
    styles[size],
    disabled && styles.disabled,
    style,
  ];

  const textStyleCombined = [
    styles.text,
    styles[`${variant}Text`],
    styles[`${size}Text`],
    disabled && styles.disabledText,
    textStyle,
  ];

  return (
    <TouchableOpacity
      style={buttonStyle}
      onPress={onPress}
      disabled={disabled}
      activeOpacity={0.8}
    >
      {icon && <>{icon}</>}
      <Text style={textStyleCombined}>{title}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  base: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 8,
    gap: 8,
  },
  // Variants
  default: {
    backgroundColor: '#2563EB',
  },
  destructive: {
    backgroundColor: '#DC2626',
  },
  outline: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  secondary: {
    backgroundColor: '#F3F4F6',
  },
  ghost: {
    backgroundColor: 'transparent',
  },
  link: {
    backgroundColor: 'transparent',
  },
  // Sizes
  default: {
    height: 36,
    paddingHorizontal: 16,
    paddingVertical: 8,
  },
  sm: {
    height: 32,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 6,
  },
  lg: {
    height: 40,
    paddingHorizontal: 24,
    paddingVertical: 10,
  },
  icon: {
    width: 36,
    height: 36,
    paddingHorizontal: 0,
    paddingVertical: 0,
  },
  // Text styles
  text: {
    fontSize: 14,
    fontWeight: '500',
  },
  defaultText: {
    color: '#FFFFFF',
  },
  destructiveText: {
    color: '#FFFFFF',
  },
  outlineText: {
    color: '#000000',
  },
  secondaryText: {
    color: '#000000',
  },
  ghostText: {
    color: '#000000',
  },
  linkText: {
    color: '#2563EB',
    textDecorationLine: 'underline',
  },
  // Size text styles
  defaultText: {
    fontSize: 14,
  },
  smText: {
    fontSize: 12,
  },
  lgText: {
    fontSize: 16,
  },
  iconText: {
    fontSize: 14,
  },
  // Disabled styles
  disabled: {
    opacity: 0.5,
  },
  disabledText: {
    opacity: 0.5,
  },
});
