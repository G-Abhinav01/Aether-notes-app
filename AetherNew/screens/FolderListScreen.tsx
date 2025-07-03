import { View, Text, FlatList, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Stack, useRouter } from 'expo-router';

const dummyFolders = [
  { id: '1', name: 'Semester Notes' },
  { id: '2', name: 'Work Projects' },
  { id: '3', name: 'Personal Ideas' },
  { id: '4', name: 'Recipes' },
  { id: '5', name: 'Travel Plans' },
];

export default function FolderListScreen() {
  const router = useRouter();
  return (
    <SafeAreaView className="flex-1 bg-gray-900">
      <Stack.Screen options={{ title: 'Folders', headerShown: false }} />
      <View className="flex-1 p-4">
        <Text className="text-white text-3xl font-bold mb-6">Folders</Text>
        <FlatList
          data={dummyFolders}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => (
            <TouchableOpacity
              className="bg-gray-800 p-4 rounded-lg mb-3 shadow-md"
              onPress={() => router.push(`/screens/NoteListScreen?folderId=${item.id}&folderName=${item.name}`)}
            >
              <Text className="text-white text-lg font-semibold">{item.name}</Text>
            </TouchableOpacity>
          )}
        />
        <TouchableOpacity className="absolute bottom-8 right-8 bg-blue-600 p-4 rounded-full shadow-lg">
          <Text className="text-white text-3xl">+</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}