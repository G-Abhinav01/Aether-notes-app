import React from 'react';
import { View, Text, Switch } from 'react-native';

const SettingsScreen = () => {
  const [isDarkMode, setIsDarkMode] = React.useState(true);

  const toggleDarkMode = () => {
    setIsDarkMode(previousState => !previousState);
    // TODO: Implement theme switching logic
  };

  return (
    <View className="flex-1 flex-row justify-between items-center bg-gray-900 p-5">
      <Text className="text-white text-lg">Dark Mode</Text>
      <Switch
        trackColor={{ false: "#767577", true: "#81b0ff" }}
        thumbColor={isDarkMode ? "#f5dd4b" : "#f4f3f4"}
        ios_backgroundColor="#3e3e3e"
        onValueChange={toggleDarkMode}
        value={isDarkMode}
      />
    </View>
  );
};

export default SettingsScreen;