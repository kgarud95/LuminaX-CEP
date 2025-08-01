import React from 'react';
import { Link } from 'react-router-dom';
import { Star, Clock, Users, BookOpen, Heart, ShoppingCart } from 'lucide-react';
import { Course } from '../../types';
import { useApp } from '../../contexts/AppContext';
import toast from 'react-hot-toast';

interface CourseCardProps {
  course: Course;
  showAddToCart?: boolean;
}

export default function CourseCard({ course, showAddToCart = true }: CourseCardProps) {
  const { state, dispatch } = useApp();

  const handleAddToCart = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    
    if (!state.user) {
      toast.error('Please login to add courses to cart');
      return;
    }

    const isAlreadyInCart = state.cart.some(item => item.courseId === course.id);
    const isEnrolled = state.enrollments.some(enrollment => 
      enrollment.courseId === course.id && enrollment.userId === state.user?.id
    );

    if (isEnrolled) {
      toast.error('You are already enrolled in this course');
      return;
    }

    if (isAlreadyInCart) {
      toast.error('Course is already in your cart');
      return;
    }

    dispatch({ type: 'ADD_TO_CART', payload: course });
    toast.success('Course added to cart');
  };

  const isEnrolled = state.user && state.enrollments.some(enrollment => 
    enrollment.courseId === course.id && enrollment.userId === state.user?.id
  );

  const isInCart = state.cart.some(item => item.courseId === course.id);

  return (
    <div className="group card overflow-hidden hover:scale-105 transition-all duration-300">
      <Link to={`/course/${course.id}`} className="block">
        <div className="relative">
          <img
            src={course.thumbnail}
            alt={course.title}
            className="w-full h-48 object-cover"
          />
          {course.originalPrice && course.originalPrice > course.price && (
            <div className="absolute top-3 left-3 bg-red-500 text-white px-2 py-1 rounded-md text-xs font-medium">
              {Math.round(((course.originalPrice - course.price) / course.originalPrice) * 100)}% OFF
            </div>
          )}
          <div className="absolute top-3 right-3 opacity-0 group-hover:opacity-100 transition-opacity">
            <button className="p-2 bg-white/90 rounded-full hover:bg-white transition-colors">
              <Heart className="h-4 w-4 text-gray-700" />
            </button>
          </div>
          {course.featured && (
            <div className="absolute bottom-3 left-3 bg-gradient-to-r from-blue-600 to-purple-600 text-white px-2 py-1 rounded-md text-xs font-medium">
              Featured
            </div>
          )}
        </div>

        <div className="p-6">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-medium text-blue-600 bg-blue-50 dark:bg-blue-900/30 dark:text-blue-400 px-2 py-1 rounded-full">
              {course.category}
            </span>
            <span className="text-xs font-medium text-gray-500 dark:text-gray-400 bg-gray-100 dark:bg-gray-800 px-2 py-1 rounded-full">
              {course.level}
            </span>
          </div>

          <h3 className="font-semibold text-lg text-gray-900 dark:text-gray-100 mb-2 line-clamp-2 group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors">
            {course.title}
          </h3>

          <p className="text-sm text-gray-600 dark:text-gray-400 mb-4 line-clamp-2">
            {course.shortDescription}
          </p>

          <div className="flex items-center space-x-2 mb-3">
            <img
              src={course.instructor.avatar}
              alt={course.instructor.name}
              className="h-6 w-6 rounded-full object-cover"
            />
            <span className="text-sm text-gray-700 dark:text-gray-300 font-medium">
              {course.instructor.name}
            </span>
          </div>

          <div className="flex items-center justify-between text-sm text-gray-500 dark:text-gray-400 mb-4">
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-1">
                <Star className="h-4 w-4 fill-yellow-400 text-yellow-400" />
                <span className="font-medium">{course.rating}</span>
                <span>({course.reviewsCount})</span>
              </div>
              <div className="flex items-center space-x-1">
                <Users className="h-4 w-4" />
                <span>{course.studentsCount.toLocaleString()}</span>
              </div>
            </div>
          </div>

          <div className="flex items-center justify-between text-sm text-gray-500 dark:text-gray-400 mb-4">
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-1">
                <Clock className="h-4 w-4" />
                <span>{course.duration}</span>
              </div>
              <div className="flex items-center space-x-1">
                <BookOpen className="h-4 w-4" />
                <span>{course.lessonsCount} lessons</span>
              </div>
            </div>
          </div>

          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <span className="text-2xl font-bold text-gray-900 dark:text-gray-100">
                ${course.price}
              </span>
              {course.originalPrice && course.originalPrice > course.price && (
                <span className="text-sm text-gray-500 dark:text-gray-400 line-through">
                  ${course.originalPrice}
                </span>
              )}
            </div>

            {showAddToCart && !isEnrolled && (
              <button
                onClick={handleAddToCart}
                disabled={isInCart}
                className={`p-2 rounded-lg transition-all ${
                  isInCart
                    ? 'bg-gray-100 dark:bg-gray-800 text-gray-400 cursor-not-allowed'
                    : 'bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 hover:bg-blue-100 dark:hover:bg-blue-900/50'
                }`}
                title={isInCart ? 'Already in cart' : 'Add to cart'}
              >
                <ShoppingCart className="h-4 w-4" />
              </button>
            )}

            {isEnrolled && (
              <Link
                to={`/learn/${course.id}`}
                className="px-4 py-2 bg-emerald-600 text-white text-sm font-medium rounded-lg hover:bg-emerald-700 transition-colors"
                onClick={(e) => e.stopPropagation()}
              >
                Continue
              </Link>
            )}
          </div>
        </div>
      </Link>
    </div>
  );
}