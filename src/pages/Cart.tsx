import React from 'react';
import { Link } from 'react-router-dom';
import { Trash2, ShoppingCart, ArrowLeft, Plus, Minus } from 'lucide-react';
import { useApp } from '../contexts/AppContext';
import toast from 'react-hot-toast';

export default function Cart() {
  const { state, dispatch } = useApp();

  const handleRemoveFromCart = (courseId: string) => {
    dispatch({ type: 'REMOVE_FROM_CART', payload: courseId });
    toast.success('Course removed from cart');
  };

  const subtotal = state.cart.reduce((total, item) => total + item.course.price, 0);
  const tax = subtotal * 0.1; // 10% tax
  const total = subtotal + tax;

  if (state.cart.length === 0) {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900 py-12">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center py-16">
            <ShoppingCart className="h-16 w-16 text-gray-400 mx-auto mb-4" />
            <h2 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-4">
              Your cart is empty
            </h2>
            <p className="text-gray-600 dark:text-gray-400 mb-8">
              Browse our courses and add some to your cart to get started.
            </p>
            <Link to="/courses" className="btn-primary">
              Browse Courses
            </Link>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 py-12">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <Link
            to="/courses"
            className="inline-flex items-center text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 transition-colors"
          >
            <ArrowLeft className="h-4 w-4 mr-2" />
            Continue Shopping
          </Link>
        </div>

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Cart Items */}
          <div className="lg:col-span-2">
            <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm">
              <div className="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
                <h2 className="text-xl font-semibold text-gray-900 dark:text-gray-100">
                  Shopping Cart ({state.cart.length} items)
                </h2>
              </div>
              
              <div className="divide-y divide-gray-200 dark:divide-gray-700">
                {state.cart.map((item) => (
                  <div key={item.courseId} className="p-6">
                    <div className="flex items-start space-x-4">
                      <img
                        src={item.course.thumbnail}
                        alt={item.course.title}
                        className="h-20 w-32 object-cover rounded-lg flex-shrink-0"
                      />
                      
                      <div className="flex-grow min-w-0">
                        <h3 className="text-lg font-medium text-gray-900 dark:text-gray-100 line-clamp-2">
                          {item.course.title}
                        </h3>
                        <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                          by {item.course.instructor.name}
                        </p>
                        <div className="flex items-center space-x-4 mt-2">
                          <span className="text-sm text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30 px-2 py-1 rounded-full">
                            {item.course.category}
                          </span>
                          <span className="text-sm text-gray-500 dark:text-gray-400">
                            {item.course.level}
                          </span>
                        </div>
                      </div>
                      
                      <div className="flex items-center space-x-4">
                        <div className="text-right">
                          <div className="text-lg font-semibold text-gray-900 dark:text-gray-100">
                            ${item.course.price}
                          </div>
                          {item.course.originalPrice && item.course.originalPrice > item.course.price && (
                            <div className="text-sm text-gray-500 dark:text-gray-400 line-through">
                              ${item.course.originalPrice}
                            </div>
                          )}
                        </div>
                        
                        <button
                          onClick={() => handleRemoveFromCart(item.courseId)}
                          className="p-2 text-gray-400 hover:text-red-500 transition-colors"
                          aria-label="Remove from cart"
                        >
                          <Trash2 className="h-5 w-5" />
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Order Summary */}
          <div className="lg:col-span-1">
            <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm sticky top-8">
              <div className="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
                <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100">
                  Order Summary
                </h3>
              </div>
              
              <div className="p-6 space-y-4">
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600 dark:text-gray-400">Subtotal</span>
                  <span className="text-gray-900 dark:text-gray-100">${subtotal.toFixed(2)}</span>
                </div>
                
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600 dark:text-gray-400">Tax</span>
                  <span className="text-gray-900 dark:text-gray-100">${tax.toFixed(2)}</span>
                </div>
                
                <div className="border-t border-gray-200 dark:border-gray-700 pt-4">
                  <div className="flex justify-between text-lg font-semibold">
                    <span className="text-gray-900 dark:text-gray-100">Total</span>
                    <span className="text-gray-900 dark:text-gray-100">${total.toFixed(2)}</span>
                  </div>
                </div>
                
                <Link
                  to="/checkout"
                  className="w-full btn-primary text-center block py-3"
                >
                  Proceed to Checkout
                </Link>
                
                <p className="text-xs text-gray-500 dark:text-gray-400 text-center">
                  30-day money-back guarantee
                </p>
              </div>
            </div>

            {/* Coupon Code */}
            <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm mt-6">
              <div className="p-6">
                <h4 className="font-medium text-gray-900 dark:text-gray-100 mb-4">
                  Have a coupon code?
                </h4>
                <div className="flex space-x-2">
                  <input
                    type="text"
                    placeholder="Enter coupon code"
                    className="flex-grow px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                  <button className="btn-secondary px-4 py-2">
                    Apply
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}