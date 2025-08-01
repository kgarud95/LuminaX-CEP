import React, { createContext, useContext, useReducer, useEffect } from 'react';
import { User, Course, CartItem, Enrollment } from '../types';
import { mockUsers, mockCourses, mockEnrollments } from '../data/mockData';

interface AppState {
  user: User | null;
  courses: Course[];
  cart: CartItem[];
  enrollments: Enrollment[];
  darkMode: boolean;
  searchQuery: string;
  selectedCategory: string;
  loading: boolean;
}

type AppAction =
  | { type: 'SET_USER'; payload: User | null }
  | { type: 'SET_COURSES'; payload: Course[] }
  | { type: 'ADD_TO_CART'; payload: Course }
  | { type: 'REMOVE_FROM_CART'; payload: string }
  | { type: 'CLEAR_CART' }
  | { type: 'SET_ENROLLMENTS'; payload: Enrollment[] }
  | { type: 'ADD_ENROLLMENT'; payload: Enrollment }
  | { type: 'TOGGLE_DARK_MODE' }
  | { type: 'SET_SEARCH_QUERY'; payload: string }
  | { type: 'SET_SELECTED_CATEGORY'; payload: string }
  | { type: 'SET_LOADING'; payload: boolean };

const initialState: AppState = {
  user: null,
  courses: [],
  cart: [],
  enrollments: [],
  darkMode: false,
  searchQuery: '',
  selectedCategory: '',
  loading: false,
};

const AppContext = createContext<{
  state: AppState;
  dispatch: React.Dispatch<AppAction>;
} | null>(null);

function appReducer(state: AppState, action: AppAction): AppState {
  switch (action.type) {
    case 'SET_USER':
      return { ...state, user: action.payload };
    case 'SET_COURSES':
      return { ...state, courses: action.payload };
    case 'ADD_TO_CART':
      const existingItem = state.cart.find(item => item.courseId === action.payload.id);
      if (existingItem) return state;
      return {
        ...state,
        cart: [...state.cart, { courseId: action.payload.id, course: action.payload }],
      };
    case 'REMOVE_FROM_CART':
      return {
        ...state,
        cart: state.cart.filter(item => item.courseId !== action.payload),
      };
    case 'CLEAR_CART':
      return { ...state, cart: [] };
    case 'SET_ENROLLMENTS':
      return { ...state, enrollments: action.payload };
    case 'ADD_ENROLLMENT':
      return { ...state, enrollments: [...state.enrollments, action.payload] };
    case 'TOGGLE_DARK_MODE':
      return { ...state, darkMode: !state.darkMode };
    case 'SET_SEARCH_QUERY':
      return { ...state, searchQuery: action.payload };
    case 'SET_SELECTED_CATEGORY':
      return { ...state, selectedCategory: action.payload };
    case 'SET_LOADING':
      return { ...state, loading: action.payload };
    default:
      return state;
  }
}

export function AppProvider({ children }: { children: React.ReactNode }) {
  const [state, dispatch] = useReducer(appReducer, initialState);

  useEffect(() => {
    // Initialize with mock data
    dispatch({ type: 'SET_COURSES', payload: mockCourses });
    dispatch({ type: 'SET_ENROLLMENTS', payload: mockEnrollments });
    
    // Check for saved user and dark mode preference
    const savedUser = localStorage.getItem('luminax_user');
    const savedDarkMode = localStorage.getItem('luminax_dark_mode');
    
    if (savedUser) {
      dispatch({ type: 'SET_USER', payload: JSON.parse(savedUser) });
    }
    
    if (savedDarkMode === 'true') {
      dispatch({ type: 'TOGGLE_DARK_MODE' });
    }
  }, []);

  useEffect(() => {
    // Update DOM class for dark mode
    if (state.darkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
    localStorage.setItem('luminax_dark_mode', state.darkMode.toString());
  }, [state.darkMode]);

  useEffect(() => {
    // Save user to localStorage
    if (state.user) {
      localStorage.setItem('luminax_user', JSON.stringify(state.user));
    } else {
      localStorage.removeItem('luminax_user');
    }
  }, [state.user]);

  return (
    <AppContext.Provider value={{ state, dispatch }}>
      {children}
    </AppContext.Provider>
  );
}

export function useApp() {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
}