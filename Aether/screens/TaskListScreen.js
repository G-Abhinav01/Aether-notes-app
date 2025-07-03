import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

const TaskListScreen = () => {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Tasks</Text>
      {/* TODO: Implement task list */}
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
});

export default TaskListScreen;