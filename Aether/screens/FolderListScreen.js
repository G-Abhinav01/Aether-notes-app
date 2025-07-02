import React from 'react';
import { View, Text, FlatList, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';

const dummyFolders = [
  { id: '1', name: 'Personal' },
  { id: '2', name: 'Work' },
  { id: '3', name: 'Ideas' },
  { id: '4', name: 'Projects' },
];

const FolderListScreen = () => {
  const router = useRouter();

  return (
    <View className="flex-1 bg-gray-900 p-2.5">
      <FlatList
        data={dummyFolders}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <TouchableOpacity onPress={() => router.push(`/notes/${item.id}`)} className="p-4 border-b border-gray-700">
            <Text className="text-white text-lg">{item.name}</Text>
          </TouchableOpacity>
        )}
      />
      <TouchableOpacity className="absolute right-7 bottom-7 bg-blue-500 w-14 h-14 rounded-full justify-center items-center shadow-lg">
        <Text className="text-white text-3xl">+</Text>
      </TouchableOpacity>
    </View>
  );
};

export default FolderListScreen;