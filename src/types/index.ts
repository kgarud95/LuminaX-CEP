export interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  role: 'student' | 'instructor' | 'admin';
  bio?: string;
  website?: string;
  createdAt: string;
}

export interface Course {
  id: string;
  title: string;
  description: string;
  shortDescription: string;
  thumbnail: string;
  price: number;
  originalPrice?: number;
  category: string;
  level: 'Beginner' | 'Intermediate' | 'Advanced';
  duration: string;
  lessonsCount: number;
  studentsCount: number;
  rating: number;
  reviewsCount: number;
  instructor: {
    id: string;
    name: string;
    avatar: string;
    bio: string;
  };
  whatYouWillLearn: string[];
  requirements: string[];
  curriculum: Module[];
  tags: string[];
  featured: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface Module {
  id: string;
  title: string;
  lessons: Lesson[];
  duration: string;
}

export interface Lesson {
  id: string;
  title: string;
  duration: string;
  type: 'video' | 'text' | 'quiz';
  videoUrl?: string;
  content?: string;
  resources?: Resource[];
}

export interface Resource {
  id: string;
  title: string;
  type: 'pdf' | 'zip' | 'link';
  url: string;
}

export interface Enrollment {
  id: string;
  userId: string;
  courseId: string;
  progress: number;
  completedLessons: string[];
  enrolledAt: string;
  completedAt?: string;
  status: 'active' | 'completed' | 'paused';
}

export interface Review {
  id: string;
  userId: string;
  courseId: string;
  rating: number;
  comment: string;
  userName: string;
  userAvatar: string;
  createdAt: string;
}

export interface CartItem {
  courseId: string;
  course: Course;
}