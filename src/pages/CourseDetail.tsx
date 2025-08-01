import React, { useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { 
  Star, Clock, Users, BookOpen, Play, ChevronDown, ChevronUp, 
  Shield, Globe, Award, Download, Heart, Share2, ShoppingCart,
  CheckCircle
} from 'lucide-react';
import { useApp } from '../contexts/AppContext';
import { mockReviews } from '../data/mockData';
import toast from 'react-hot-toast';

export default function CourseDetail() {
  const { id } = useParams<{ id: string }>();
  const { state, dispatch } = useApp();
  const [expandedModule, setExpandedModule] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<'overview' | 'curriculum' | 'instructor' | 'reviews'>('overview');

  const course = state.courses.find(c => c.id === id);
  const courseReviews = mockReviews.filter(r => r.courseId === id);
  
  if (!course) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-4">Course not found</h2>
          <Link to="/courses" className="btn-primary">
            Browse Courses
          </Link>
        </div>
      </div>
    );
  }

  const isEnrolled = state.user && state.enrollments.some(enrollment => 
    enrollment.courseId === course.id && enrollment.userId === state.user?.id
  );

  const isInCart = state.cart.some(item => item.courseId === course.id);

  const handleAddToCart = () => {
    if (!state.user) {
      toast.error('Please login to add courses to cart');
      return;
    }

    if (isEnrolled) {
      toast.error('You are already enrolled in this course');
      return;
    }

    if (isInCart) {
      toast.error('Course is already in your cart');
      return;
    }

    dispatch({ type: 'ADD_TO_CART', payload: course });
    toast.success('Course added to cart');
  };

  const handleEnrollNow = () => {
    if (!state.user) {
      toast.error('Please login to enroll in courses');
      return;
    }

    if (isEnrolled) {
      toast.error('You are already enrolled in this course');
      return;
    }

    // Add to cart and redirect to checkout
    if (!isInCart) {
      dispatch({ type: 'ADD_TO_CART', payload: course });
    }
    window.location.href = '/checkout';
  };

  const toggleModule = (moduleId: string) => {
    setExpandedModule(expandedModule === moduleId ? null : moduleId);
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Hero Section */}
      <div className="bg-gray-900 text-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="grid lg:grid-cols-3 gap-12">
            <div className="lg:col-span-2 space-y-6">
              <div className="flex items-center space-x-2 text-blue-400">
                <span className="text-sm font-medium">{course.category}</span>
                <span className="text-gray-400">•</span>
                <span className="text-sm">{course.level}</span>
              </div>
              
              <h1 className="text-4xl font-bold leading-tight">
                {course.title}
              </h1>
              
              <p className="text-xl text-gray-300 leading-relaxed">
                {course.description}
              </p>

              <div className="flex items-center space-x-6 text-sm">
                <div className="flex items-center space-x-2">
                  <div className="flex items-center space-x-1">
                    <Star className="h-5 w-5 fill-yellow-400 text-yellow-400" />
                    <span className="font-medium">{course.rating}</span>
                  </div>
                  <span className="text-gray-300">({course.reviewsCount} reviews)</span>
                </div>
                <div className="flex items-center space-x-1">
                  <Users className="h-5 w-5 text-gray-400" />
                  <span>{course.studentsCount.toLocaleString()} students</span>
                </div>
                <div className="flex items-center space-x-1">
                  <Clock className="h-5 w-5 text-gray-400" />
                  <span>{course.duration}</span>
                </div>
              </div>

              <div className="flex items-center space-x-4">
                <img
                  src={course.instructor.avatar}
                  alt={course.instructor.name}
                  className="h-12 w-12 rounded-full object-cover"
                />
                <div>
                  <p className="text-sm text-gray-400">Created by</p>
                  <p className="font-semibold">{course.instructor.name}</p>
                </div>
              </div>
            </div>

            {/* Course Preview Card */}
            <div className="lg:col-span-1">
              <div className="bg-white dark:bg-gray-800 rounded-xl shadow-xl overflow-hidden sticky top-8">
                <div className="relative">
                  <img
                    src={course.thumbnail}
                    alt={course.title}
                    className="w-full h-48 object-cover"
                  />
                  <div className="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
                    <button className="bg-white bg-opacity-20 backdrop-blur-sm border border-white border-opacity-30 rounded-full p-4 hover:bg-opacity-30 transition-all">
                      <Play className="h-8 w-8 text-white ml-1" />
                    </button>
                  </div>
                </div>

                <div className="p-6 space-y-6">
                  <div className="flex items-baseline space-x-2">
                    <span className="text-3xl font-bold text-gray-900 dark:text-gray-100">
                      ${course.price}
                    </span>
                    {course.originalPrice && course.originalPrice > course.price && (
                      <span className="text-lg text-gray-500 dark:text-gray-400 line-through">
                        ${course.originalPrice}
                      </span>
                    )}
                  </div>

                  {isEnrolled ? (
                    <Link
                      to={`/learn/${course.id}`}
                      className="w-full btn-primary text-center block"
                    >
                      Continue Learning
                    </Link>
                  ) : (
                    <div className="space-y-3">
                      <button
                        onClick={handleEnrollNow}
                        className="w-full btn-primary"
                      >
                        Enroll Now
                      </button>
                      <button
                        onClick={handleAddToCart}
                        disabled={isInCart}
                        className={`w-full btn-secondary flex items-center justify-center space-x-2 ${
                          isInCart ? 'opacity-50 cursor-not-allowed' : ''
                        }`}
                      >
                        <ShoppingCart className="h-4 w-4" />
                        <span>{isInCart ? 'In Cart' : 'Add to Cart'}</span>
                      </button>
                    </div>
                  )}

                  <div className="text-center text-sm text-gray-600 dark:text-gray-400">
                    30-Day Money-Back Guarantee
                  </div>

                  <div className="space-y-4">
                    <h4 className="font-semibold text-gray-900 dark:text-gray-100">This course includes:</h4>
                    <div className="space-y-2 text-sm">
                      <div className="flex items-center space-x-2">
                        <Clock className="h-4 w-4 text-gray-500" />
                        <span>{course.duration} on-demand video</span>
                      </div>
                      <div className="flex items-center space-x-2">
                        <BookOpen className="h-4 w-4 text-gray-500" />
                        <span>{course.lessonsCount} lessons</span>
                      </div>
                      <div className="flex items-center space-x-2">
                        <Download className="h-4 w-4 text-gray-500" />
                        <span>Downloadable resources</span>
                      </div>
                      <div className="flex items-center space-x-2">
                        <Globe className="h-4 w-4 text-gray-500" />
                        <span>Full lifetime access</span>
                      </div>
                      <div className="flex items-center space-x-2">
                        <Award className="h-4 w-4 text-gray-500" />
                        <span>Certificate of completion</span>
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center justify-between pt-4 border-t border-gray-200 dark:border-gray-700">
                    <button className="flex items-center space-x-1 text-gray-600 dark:text-gray-400 hover:text-red-500 transition-colors">
                      <Heart className="h-4 w-4" />
                      <span className="text-sm">Wishlist</span>
                    </button>
                    <button className="flex items-center space-x-1 text-gray-600 dark:text-gray-400 hover:text-blue-500 transition-colors">
                      <Share2 className="h-4 w-4" />
                      <span className="text-sm">Share</span>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Course Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid lg:grid-cols-3 gap-12">
          <div className="lg:col-span-2">
            {/* Navigation Tabs */}
            <div className="border-b border-gray-200 dark:border-gray-700 mb-8">
              <nav className="flex space-x-8">
                {[
                  { id: 'overview', label: 'Overview' },
                  { id: 'curriculum', label: 'Curriculum' },
                  { id: 'instructor', label: 'Instructor' },
                  { id: 'reviews', label: 'Reviews' },
                ].map((tab) => (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id as any)}
                    className={`py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                      activeTab === tab.id
                        ? 'border-blue-500 text-blue-600 dark:text-blue-400'
                        : 'border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300'
                    }`}
                  >
                    {tab.label}
                  </button>
                ))}
              </nav>
            </div>

            {/* Tab Content */}
            {activeTab === 'overview' && (
              <div className="space-y-8">
                <div>
                  <h3 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-4">
                    What you'll learn
                  </h3>
                  <div className="grid md:grid-cols-2 gap-4">
                    {course.whatYouWillLearn.map((item, index) => (
                      <div key={index} className="flex items-start space-x-3">
                        <CheckCircle className="h-5 w-5 text-green-500 mt-0.5 flex-shrink-0" />
                        <span className="text-gray-700 dark:text-gray-300">{item}</span>
                      </div>
                    ))}
                  </div>
                </div>

                <div>
                  <h3 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-4">
                    Requirements
                  </h3>
                  <ul className="space-y-2">
                    {course.requirements.map((requirement, index) => (
                      <li key={index} className="flex items-start space-x-3">
                        <div className="h-2 w-2 bg-gray-400 rounded-full mt-2 flex-shrink-0"></div>
                        <span className="text-gray-700 dark:text-gray-300">{requirement}</span>
                      </li>
                    ))}
                  </ul>
                </div>

                <div>
                  <h3 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-4">
                    Course Description
                  </h3>
                  <div className="prose dark:prose-invert max-w-none">
                    <p className="text-gray-700 dark:text-gray-300 leading-relaxed">
                      {course.description}
                    </p>
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'curriculum' && (
              <div className="space-y-4">
                <h3 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-6">
                  Course Curriculum
                </h3>
                {course.curriculum.map((module) => (
                  <div key={module.id} className="border border-gray-200 dark:border-gray-700 rounded-lg">
                    <button
                      onClick={() => toggleModule(module.id)}
                      className="w-full px-6 py-4 flex items-center justify-between text-left hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                    >
                      <div>
                        <h4 className="font-medium text-gray-900 dark:text-gray-100">
                          {module.title}
                        </h4>
                        <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
                          {module.lessons.length} lessons • {module.duration}
                        </p>
                      </div>
                      {expandedModule === module.id ? (
                        <ChevronUp className="h-5 w-5 text-gray-500" />
                      ) : (
                        <ChevronDown className="h-5 w-5 text-gray-500" />
                      )}
                    </button>
                    
                    {expandedModule === module.id && (
                      <div className="px-6 pb-4">
                        <div className="space-y-3 ml-4">
                          {module.lessons.map((lesson) => (
                            <div key={lesson.id} className="flex items-center space-x-3 py-2">
                              <Play className="h-4 w-4 text-gray-400" />
                              <span className="text-sm text-gray-700 dark:text-gray-300 flex-grow">
                                {lesson.title}
                              </span>
                              <span className="text-sm text-gray-500 dark:text-gray-400">
                                {lesson.duration}
                              </span>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}

            {activeTab === 'instructor' && (
              <div className="space-y-6">
                <h3 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
                  About the Instructor
                </h3>
                <div className="flex items-start space-x-6">
                  <img
                    src={course.instructor.avatar}
                    alt={course.instructor.name}
                    className="h-24 w-24 rounded-full object-cover"
                  />
                  <div className="flex-grow">
                    <h4 className="text-xl font-semibold text-gray-900 dark:text-gray-100 mb-2">
                      {course.instructor.name}
                    </h4>
                    <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                      {course.instructor.bio}
                    </p>
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'reviews' && (
              <div className="space-y-6">
                <div className="flex items-center justify-between">
                  <h3 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
                    Student Reviews
                  </h3>
                  <div className="flex items-center space-x-2">
                    <Star className="h-5 w-5 fill-yellow-400 text-yellow-400" />
                    <span className="font-semibold text-gray-900 dark:text-gray-100">
                      {course.rating}
                    </span>
                    <span className="text-gray-500 dark:text-gray-400">
                      ({course.reviewsCount} reviews)
                    </span>
                  </div>
                </div>

                <div className="space-y-6">
                  {courseReviews.map((review) => (
                    <div key={review.id} className="border-b border-gray-200 dark:border-gray-700 pb-6">
                      <div className="flex items-start space-x-4">
                        <img
                          src={review.userAvatar}
                          alt={review.userName}
                          className="h-10 w-10 rounded-full object-cover"
                        />
                        <div className="flex-grow">
                          <div className="flex items-center space-x-3 mb-2">
                            <h5 className="font-medium text-gray-900 dark:text-gray-100">
                              {review.userName}
                            </h5>
                            <div className="flex items-center space-x-1">
                              {[...Array(review.rating)].map((_, i) => (
                                <Star key={i} className="h-4 w-4 fill-yellow-400 text-yellow-400" />
                              ))}
                            </div>
                            <span className="text-sm text-gray-500 dark:text-gray-400">
                              {new Date(review.createdAt).toLocaleDateString()}
                            </span>
                          </div>
                          <p className="text-gray-700 dark:text-gray-300 leading-relaxed">
                            {review.comment}
                          </p>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* Sidebar */}
          <div className="lg:col-span-1">
            <div className="space-y-6">
              {/* Tags */}
              <div className="bg-white dark:bg-gray-800 rounded-lg p-6 shadow-sm">
                <h4 className="font-semibold text-gray-900 dark:text-gray-100 mb-4">Tags</h4>
                <div className="flex flex-wrap gap-2">
                  {course.tags.map((tag) => (
                    <span
                      key={tag}
                      className="px-3 py-1 bg-blue-50 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 text-sm rounded-full"
                    >
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              {/* Features */}
              <div className="bg-white dark:bg-gray-800 rounded-lg p-6 shadow-sm">
                <h4 className="font-semibold text-gray-900 dark:text-gray-100 mb-4">Features</h4>
                <div className="space-y-3 text-sm">
                  <div className="flex items-center space-x-2">
                    <Shield className="h-4 w-4 text-green-500" />
                    <span className="text-gray-700 dark:text-gray-300">Lifetime access</span>
                  </div>
                  <div className="flex items-center space-x-2">
                    <Award className="h-4 w-4 text-blue-500" />
                    <span className="text-gray-700 dark:text-gray-300">Certificate included</span>
                  </div>
                  <div className="flex items-center space-x-2">
                    <Download className="h-4 w-4 text-purple-500" />
                    <span className="text-gray-700 dark:text-gray-300">Downloadable resources</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}