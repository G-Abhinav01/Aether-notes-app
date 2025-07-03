import { Stack } from 'expo-router';

export default function NoteDetailLayout() {
  return (
    <Stack>
      <Stack.Screen name="[noteId]" options={{ headerShown: false }} />
    </Stack>
  );
}