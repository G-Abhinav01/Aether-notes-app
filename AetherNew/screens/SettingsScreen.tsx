import { View, Text, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Stack } from 'expo-router';
import { useState } from 'react';

export default function SettingsScreen() {
  const [isDarkMode, setIsDarkMode] = useState(true); // Assuming dark mode is default

  const toggleDarkMode = () => {
    setIsDarkMode(!isDarkMode);
    // TODO: Implement actual theme switching logic
  };

  return (
    <SafeAreaView className="flex-1 bg-gray-900">
      <Stack.Screen options={{ title: 'Settings', headerShown: false }} />
      <View className="flex-1 p-4">
        <Text className="text-white text-3xl font-bold mb-6">Settings</Text>

        <View className="flex-row items-center justify-between bg-gray-800 p-4 rounded-lg mb-4">
          <Text className="text-white text-lg">Dark Mode</Text>
          <TouchableOpacity
            className={`w-14 h-8 rounded-full p-1 ${isDarkMode ? 'bg-blue-600' : 'bg-gray-600'}`}
            onPress={toggleDarkMode}
          >
            <View
              className={`w-6 h-6 rounded-full bg-white shadow-md ${isDarkMode ? 'self-end' : 'self-start'}`}
            />
          </TouchableOpacity>
        </View>

        {/* Add more settings options here */}
      </View>
    </SafeAreaView>
  );
}