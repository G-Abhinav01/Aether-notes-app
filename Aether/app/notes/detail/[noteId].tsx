import NoteDetailScreen from '../../../../screens/NoteDetailScreen';
import { useLocalSearchParams } from 'expo-router';

export default function NoteDetail() {
  const { noteId } = useLocalSearchParams();
  return <NoteDetailScreen noteId={noteId} />;
}