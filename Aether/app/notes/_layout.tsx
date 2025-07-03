import { Stack } from 'expo-router';

export default function NotesLayout() {
  return (
    <Stack>
      <Stack.Screen name="[folderId]" options={{ headerShown: false }} />
      <Stack.Screen name="detail/[noteId]" options={{ title: 'Note Detail' }} />
    </Stack>
  );
}