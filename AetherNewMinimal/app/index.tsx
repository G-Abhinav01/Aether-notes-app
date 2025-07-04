import { StyleSheet, Text, View } from "react-native";
import { Link } from "expo-router";

export default function Index() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Welcome to Aether Notes!</Text>
      <Text style={styles.subtitle}>Your personal space for thoughts and ideas.</Text>
      <Link href="/(tabs)/notes" style={styles.link}>Go to Notes</Link>
      <Link href="/(tabs)/folders" style={styles.link}>View Folders</Link>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#f0f0f0",
  },
  title: {
    fontSize: 28,
    fontWeight: "bold",
    marginBottom: 10,
    color: "#333",
  },
  subtitle: {
    fontSize: 16,
    color: "#666",
    marginBottom: 20,
  },
  link: {
    fontSize: 18,
    color: "#007AFF",
    marginTop: 10,
  },
});