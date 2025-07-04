import { StyleSheet, Text, View } from 'react-native';

export default function FoldersScreen() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Folder List Screen</Text>
      <Text>This is where your folders will be displayed.</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
  },
});