import { View, Text, FlatList, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Stack } from 'expo-router';

const dummyTasks = [
  { id: '1', text: 'Buy groceries', completed: false, dueDate: '2024-07-20' },
  { id: '2', text: 'Finish report', completed: true, dueDate: '2024-07-18' },
  { id: '3', text: 'Call John', completed: false, dueDate: '2024-07-22' },
  { id: '4', text: 'Schedule dentist', completed: false, dueDate: '2024-07-25' },
  { id: '5', text: 'Pay bills', completed: true, dueDate: '2024-07-15' },
];

export default function TaskListScreen() {
  return (
    <SafeAreaView className="flex-1 bg-gray-900">
      <Stack.Screen options={{ title: 'Tasks', headerShown: false }} />
      <View className="flex-1 p-4">
        <Text className="text-white text-3xl font-bold mb-6">Tasks</Text>
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
      </View>
    </SafeAreaView>
  );
}