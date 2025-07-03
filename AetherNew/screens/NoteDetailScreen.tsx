import { View, Text, TextInput, ScrollView, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Stack } from 'expo-router';

export default function NoteDetailScreen() {
  return (
    <SafeAreaView className="flex-1 bg-gray-900">
      <Stack.Screen options={{ title: 'Note Detail', headerShown: false }} />
      <ScrollView className="flex-1 p-4">
        <TextInput
          className="text-white text-3xl font-bold mb-4 bg-gray-800 p-3 rounded-lg"
          placeholder="Note Title"
          placeholderTextColor="#9ca3af"
        />
        <TextInput
          className="text-white text-lg mb-4 bg-gray-800 p-3 rounded-lg h-48 text-top"
          placeholder="Note Content"
          placeholderTextColor="#9ca3af"
          multiline
          textAlignVertical="top"
        />
        <View className="flex-row flex-wrap mb-4">
          <TouchableOpacity className="bg-gray-700 px-3 py-1 rounded-full mr-2 mb-2">
            <Text className="text-gray-300 text-sm">Tag 1</Text>
          </TouchableOpacity>
          <TouchableOpacity className="bg-gray-700 px-3 py-1 rounded-full mr-2 mb-2">
            <Text className="text-gray-300 text-sm">Tag 2</Text>
          </TouchableOpacity>
        </View>
        <View className="w-full h-48 bg-gray-800 rounded-lg justify-center items-center mb-4">
          <Text className="text-gray-400">Placeholder for Image Preview</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}