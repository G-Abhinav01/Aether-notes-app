import NoteListScreen from '../../../screens/NoteListScreen';
import { useLocalSearchParams } from 'expo-router';

export default function NoteList() {
  const { folderId } = useLocalSearchParams();
  return <NoteListScreen folderId={folderId} />;
}