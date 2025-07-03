import { View, Text, TextInput } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Stack } from 'expo-router';

export default function SearchScreen() {
  return (
    <SafeAreaView className="flex-1 bg-gray-900">
      <Stack.Screen options={{ title: 'Search', headerShown: false }} />
      <View className="flex-1 p-4">
        <Text className="text-white text-3xl font-bold mb-6">Search</Text>
        <TextInput
          className="bg-gray-800 p-3 rounded-lg text-white text-lg mb-4"
          placeholder="Search notes, tasks, folders..."
          placeholderTextColor="#9ca3af"
        />
        <Text className="text-gray-400 text-center">Search results will appear here.</Text>
      </View>
    </SafeAreaView>
  );
}