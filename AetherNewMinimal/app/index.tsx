import { StyleSheet } from "react-native";
import { Link } from "expo-router";
import { ThemedText } from '@/components/ThemedText';
import { ThemedView } from '@/components/ThemedView';

export default function Index() {
  return (
    <ThemedView style={styles.container}>
      <ThemedText type="title">Welcome to Aether Notes!</ThemedText>
      <ThemedText type="subtitle">Your personal space for thoughts and ideas.</ThemedText>
      <Link href="/(tabs)/notes" style={styles.link}>Go to Notes</Link>
      <Link href="/(tabs)/folders" style={styles.link}>View Folders</Link>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  link: {
    fontSize: 18,
    marginTop: 10,
  },
});