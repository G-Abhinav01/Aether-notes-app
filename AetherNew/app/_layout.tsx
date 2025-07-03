import { Stack } from 'expo-router';

export default function Layout() {
  return (
    <Stack>
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      <Stack.Screen name="screens/FolderListScreen" options={{ presentation: 'modal', headerShown: false }} />
      <Stack.Screen name="screens/NoteListScreen" options={{ presentation: 'modal', headerShown: false }} />
      <Stack.Screen name="screens/NoteDetailScreen" options={{ presentation: 'modal', headerShown: false }} />
      <Stack.Screen name="screens/TaskListScreen" options={{ presentation: 'modal', headerShown: false }} />
      <Stack.Screen name="screens/SettingsScreen" options={{ presentation: 'modal', headerShown: false }} />
      <Stack.Screen name="screens/SearchScreen" options={{ presentation: 'modal', headerShown: false }} />
    </Stack>
  );
}