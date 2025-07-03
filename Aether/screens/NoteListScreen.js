import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';

const NoteListScreen = ({ folderId }) => {
  const router = useRouter();

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Folder {folderId}</Text>
      {/* TODO: Implement note and task lists */}
      <TouchableOpacity onPress={() => router.push('/notes/detail/1')}>
        <Text style={styles.note}>Sample Note</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#1a1a1a',
    padding: 10,
  },
  title: {
    color: 'white',
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
  },
  note: {
    color: 'white',
    fontSize: 18,
    padding: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#333',
  },
});

export default NoteListScreen;