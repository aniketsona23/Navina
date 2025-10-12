import React, { useState } from 'react';
import { Image, View, Text, StyleSheet, ImageProps, ViewStyle } from 'react-native';

interface ImageWithFallbackProps extends ImageProps {
  fallbackText?: string;
  containerStyle?: ViewStyle;
}

export function ImageWithFallback({
  source,
  style,
  containerStyle,
  fallbackText = 'Image not available',
  ...props
}: ImageWithFallbackProps) {
  const [didError, setDidError] = useState(false);

  const handleError = () => {
    setDidError(true);
  };

  if (didError) {
    return (
      <View style={[styles.fallbackContainer, containerStyle, style]}>
        <Text style={styles.fallbackText}>{fallbackText}</Text>
      </View>
    );
  }

  return (
    <Image
      source={source}
      style={style}
      onError={handleError}
      {...props}
    />
  );
}

const styles = StyleSheet.create({
  fallbackContainer: {
    backgroundColor: '#F3F4F6',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 8,
  },
  fallbackText: {
    color: '#6B7280',
    fontSize: 12,
    textAlign: 'center',
  },
});
