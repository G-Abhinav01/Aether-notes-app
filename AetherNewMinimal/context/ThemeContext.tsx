import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { Appearance, ColorSchemeName, Platform } from 'react-native';

interface ThemeContextType {
  colorScheme: ColorSchemeName;
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export const ThemeProvider = ({ children }: { children: ReactNode }) => {
  const [colorScheme, setColorScheme] = useState<ColorSchemeName>(
    Platform.OS === 'web' ? 'dark' : Appearance.getColorScheme() || 'dark'
  ); // Set dark theme as default, handle web



  useEffect(() => {
    const subscription = Appearance.addChangeListener(({ colorScheme }) => {
      setColorScheme(colorScheme);
    });
    return () => subscription.remove();
  }, []);

  const toggleTheme = () => {
    const newColorScheme = colorScheme === 'dark' ? 'light' : 'dark';
    if (Platform.OS !== 'web') {
      Appearance.setColorScheme(newColorScheme);
    }
    setColorScheme(newColorScheme);
  };

  return (
    <ThemeContext.Provider value={{ colorScheme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
};