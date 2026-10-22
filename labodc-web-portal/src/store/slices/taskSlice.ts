// Task Slice
import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { ITask } from '@/types/task.types';

interface TaskState {
  tasks: ITask[];
  currentTask: ITask | null;
  loading: boolean;
  error: string | null;
}

const initialState: TaskState = {
  tasks: [],
  currentTask: null,
  loading: false,
  error: null,
};

const taskSlice = createSlice({
  name: 'task',
  initialState,
  reducers: {
    setTasks: (state, action: PayloadAction<ITask[]>) => {
      state.tasks = action.payload;
    },
    setCurrentTask: (state, action: PayloadAction<ITask>) => {
      state.currentTask = action.payload;
    },
    clearCurrentTask: (state) => {
      state.currentTask = null;
    },
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.loading = action.payload;
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload;
    },
  },
});

export const { setTasks, setCurrentTask, clearCurrentTask, setLoading, setError } =
  taskSlice.actions;
export default taskSlice.reducer;
