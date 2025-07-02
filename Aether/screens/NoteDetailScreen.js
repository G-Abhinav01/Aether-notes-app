import React from 'react';
import { View, Text, TextInput } from 'react-native';

const NoteDetailScreen = ({ noteId }) => {
  return (
    <View className="flex-1 bg-gray-900 p-5">
      <Text className="text-gray-400 text-center mb-2.5">Note ID: {noteId}</Text>
      <TextInput
        className="text-white text-2xl font-bold border-b border-gray-700 mb-5"
        placeholder="Title"
        placeholderTextColor="#888"
      />
      <TextInput
        className="text-white text-lg flex-1"
        placeholder="Content"
        placeholderTextColor="#888"
        multiline
      />
      {/* TODO: Add tag chips UI and image preview */}
    </View>
  );
};

export default NoteDetailScreen;