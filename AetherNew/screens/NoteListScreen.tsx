import { View, Text, FlatList, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Stack, useRouter } from 'expo-router';
import { useState } from 'react';

const dummyNotes = [
  { id: '1', title: 'Meeting Notes', preview: 'Discussed Q3 strategy...', tags: ['work', 'strategy'] },
  { id: '2', title: 'Recipe: Pasta', preview: 'Ingredients: pasta, tomatoes...', tags: ['personal', 'cooking'] },
  { id: '3', title: 'Book Summary', preview: 'Chapter 1: Introduction to...', tags: ['study', 'reading'] },
];

const dummyTasks = [
  { id: '1', text: 'Buy groceries', completed: false, dueDate: '2024-07-20' },
  { id: '2', text: 'Finish report', completed: true, dueDate: '2024-07-18' },
  { id: '3', text: 'Call John', completed: false, dueDate: '2024-07-22' },
];

export default function NoteListScreen() {
  const [showNotes, setShowNotes] = useState(true);
  const router = useRouter();

  return (
    <SafeAreaView className="flex-1 bg-gray-900">
      <Stack.Screen options={{ title: 'Notes', headerShown: false }} />
      <View className="flex-1 p-4">
        <Text className="text-white text-3xl font-bold mb-6">Notes & Tasks</Text>

        <View className="flex-row mb-4 bg-gray-800 rounded-lg p-1">
          <TouchableOpacity
            className={`flex-1 py-2 rounded-md ${showNotes ? 'bg-blue-600' : ''}`}
            onPress={() => setShowNotes(true)}
          >
            <Text className="text-white text-center font-semibold">Notes</Text>
          </TouchableOpacity>
          <TouchableOpacity
            className={`flex-1 py-2 rounded-md ${!showNotes ? 'bg-blue-600' : ''}`}
            onPress={() => setShowNotes(false)}
          >
            <Text className="text-white text-center font-semibold">Tasks</Text>
          </TouchableOpacity>
        </View>

        {showNotes ? (
          <FlatList
            data={dummyNotes}
            keyExtractor={(item) => item.id}
            renderItem={({ item }) => (
              <TouchableOpacity
                className="bg-gray-800 p-4 rounded-lg mb-3 shadow-md"
                onPress={() => router.push(`/screens/NoteDetailScreen?noteId=${item.id}&noteTitle=${item.title}`)}
              >
                <Text className="text-white text-lg font-semibold mb-1">{item.title}</Text>
                <Text className="text-gray-400 text-sm mb-2">{item.preview}</Text>
                <View className="flex-row flex-wrap">
                  {item.tags.map((tag, index) => (
                    <Text key={index} className="bg-gray-700 text-gray-300 text-xs px-2 py-1 rounded-full mr-2 mb-1">
                      {tag}
                    </Text>
                  ))}
                </View>
              </TouchableOpacity>
            )}
          />
        ) : (
          <FlatList
            data={dummyTasks}
            keyExtractor={(item) => item.id}
            renderItem={({ item }) => (
              <TouchableOpacity className="bg-gray-800 p-4 rounded-lg mb-3 shadow-md flex-row items-center">
                <View className={`w-5 h-5 rounded-full border-2 mr-3 ${item.completed ? 'bg-blue-600 border-blue-600' : 'border-gray-500'}`} />
                <View className="flex-1">
                  <Text className={`text-white text-lg ${item.completed ? 'line-through text-gray-500' : ''}`}>{item.text}</Text>
                  {item.dueDate && <Text className="text-gray-400 text-sm">Due: {item.dueDate}</Text>}
                </View>
              </TouchableOpacity>
            )}
          />
        )}
      </View>
    </SafeAreaView>
  );
}