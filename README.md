# Food Ordering App

This project is a comprehensive food ordering application, similar to Swiggy and Zomato, with three separate apps for users, sellers, and riders. The app is fully integrated with Firebase for authentication, database, storage, and other backend services, along with Google Maps integration for location-based services.

## App Links
   - <h1><a href="https://drive.google.com/drive/folders/1Wb2ZBByOawVq2hYk7lAn0zm_rB29l-VT?usp=sharing" >Applications</a></h1>
## Features

### User App
- Browse and search for restaurants and dishes.
- View detailed restaurant and dish information.
- Place orders with multiple payment options.
- Track order status in real-time.
- Integrated with Google Maps for location-based restaurant recommendations.

### Seller App
- Manage restaurant profile, menu, and pricing.
- Receive and manage orders in real-time.
- Track order status and update customers.
- View order history and analytics.

### Rider App
- Receive delivery requests with route optimization.
- Track delivery locations using Google Maps.
- Update order status and communicate with customers.

## Technologies Used

- **Frontend**: Flutter
- **Backend**: Firebase (Authentication, Firestore, Cloud Functions, Storage)
- **Maps Integration**: Google Maps API
- **State Management**: Provider

## Firebase Services

- **Authentication**: User, Seller, and Rider authentication with email/password and social login options.
- **Firestore**: Real-time database for storing user profiles, orders, and restaurant data.
- **Cloud Functions**: Serverless functions for handling complex backend logic like notifications and order processing.
- **Cloud Storage**: Storing images for user profiles, restaurant menus, and more.

## Google Maps Integration

- **User App**: Displays nearby restaurants based on user location.
- **Rider App**: Provides optimized routes for deliveries.
- **Seller App**: Allows sellers to view delivery locations.

## Setup and Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Chandu-geesala/Food-Ordering-App.git
