import { StyleSheet } from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import { ThemedView } from '@/components/ThemedView';

export default function FoldersScreen() {
  return (
    <ThemedView style={styles.container}>
      <ThemedText type="title">Folder List Screen</ThemedText>
      <ThemedText>This is where your folders will be displayed.</ThemedText>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});