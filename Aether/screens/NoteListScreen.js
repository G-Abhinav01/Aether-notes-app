import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';

const NoteListScreen = ({ folderId }) => {
  const router = useRouter();

  return (
    <View className="flex-1 bg-gray-900 p-2.5">
      <Text className="text-white text-2xl font-bold mb-5">Folder {folderId}</Text>
      {/* TODO: Implement note and task lists */}
      <TouchableOpacity onPress={() => router.push('/notes/detail/1')} className="p-4 border-b border-gray-700">
        <Text className="text-white text-lg">Sample Note</Text>
      </TouchableOpacity>
    </View>
  );
};

export default NoteListScreen;