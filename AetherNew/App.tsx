import { StatusBar } from 'expo-status-bar';
import { Stack } from 'expo-router';
import './global.css';

export default function App() {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ headerShown: false }} />
    </Stack>
  );
}
