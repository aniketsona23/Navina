import React, { createContext, useContext, useState, ReactNode } from 'react';
import { Screen } from '@/types/navigation';

interface NavigationContextType {
  currentScreen: Screen;
  navigate: (screen: Screen) => void;
}

const NavigationContext = createContext<NavigationContextType | undefined>(undefined);

interface NavigationProviderProps {
  children: ReactNode;
}

export function NavigationProvider({ children }: NavigationProviderProps) {
  const [currentScreen, setCurrentScreen] = useState<Screen>('home');

  const navigate = (screen: Screen) => {
    setCurrentScreen(screen);
  };

  return (
    <NavigationContext.Provider value={{ currentScreen, navigate }}>
      {children}
    </NavigationContext.Provider>
  );
}

export function useNavigation() {
  const context = useContext(NavigationContext);
  if (context === undefined) {
    throw new Error('useNavigation must be used within a NavigationProvider');
  }
  return context;
}
