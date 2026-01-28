# 🎓 Student-Teacher Portal (Flutter + Firebase)

<table>
  <tr>
    <td><img src="https://github.com/VivekPatil-2006/College-ERP-Flutter-App/blob/main/student_1.jpeg" width="250"/></td>
    <td><img src="https://github.com/VivekPatil-2006/College-ERP-Flutter-App/blob/main/student_2.jpeg" width="250"/></td>
    <td><img src="https://github.com/VivekPatil-2006/College-ERP-Flutter-App/blob/main/student_3.jpeg" width="250"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/VivekPatil-2006/College-ERP-Flutter-App/blob/main/teacher_1.jpeg" width="250"/></td>
    <td><img src="https://github.com/VivekPatil-2006/College-ERP-Flutter-App/blob/main/teacher_2.jpeg" width="250"/></td>
    <td><img src="https://github.com/VivekPatil-2006/College-ERP-Flutter-App/blob/main/teacher_3.jpeg" width="250"/></td>
  </tr>
</table>


---

## 🚀 Features

### 👨‍🎓 Student Module

* Secure Login & Registration
* Profile Management (Photo, Personal Details, Academic Info)
* View Assignments (Filtered by Year & Department)
* Submit Assignments (Text + File Upload)
* Track Submission Status
* Receive Real-Time Notifications
* Assignment Progress Tracking

---

### 👩‍🏫 Teacher Module

* Create Assignments with:

  * Target Year
  * Target Department
  * Category & Due Date
* Edit & Delete Assignments
* View Student Submissions
* Provide Feedback
* Assignment Analytics Dashboard
* Receive Email Notification When Student Submits Assignment

---

### 🛠 Admin Module

* Manage Students
* Manage Teachers
* Search & Filter Records
* Pagination Support
* Export Teacher Data to CSV
* Dashboard Analytics
* Broadcast Announcements

---

## 🧩 Tech Stack

| Technology      | Usage               |
| --------------- | ------------------- |
| Flutter         | Frontend UI         |
| Firebase Auth   | Authentication      |
| Cloud Firestore | Database            |
| Cloudinary      | File Upload Storage |
| EmailJS         | Email Notifications |
| HTTP Package    | API Calls           |
| Material UI     | UI Components       |

---

## 📱 Screens Included

* Login & Register Screen
* Student Dashboard
* Teacher Dashboard
* Admin Dashboard
* Assignment Management
* Submission System
* Notification System
* Profile Management
* Analytics Views

---

## 📂 Project Structure

```
lib/
 ├── models/
 ├── screens/
 │    ├── student/
 │    ├── teacher/
 │    ├── admin/
 │    └── auth/
 ├── services/
 ├── main.dart
```

---

## ⚙️ Installation Steps

### 1️⃣ Clone Repository

```
git clone https://github.com/your-username/student-teacher-portal.git
```

---

### 2️⃣ Install Dependencies

```
flutter pub get
```

---

### 3️⃣ Firebase Setup

1. Create Firebase Project
2. Enable:

   * Firebase Authentication (Email/Password)
   * Cloud Firestore
3. Download:

   * google-services.json (Android)
4. Place file in:

```
android/app/
```

---

### 4️⃣ Cloudinary Setup (File Upload)

Create account on:

[https://cloudinary.com](https://cloudinary.com)

Add your keys inside:

```
cloudinary_service.dart
```

---

### 5️⃣ EmailJS Setup (Teacher Email Notification)

Create free account:

[https://www.emailjs.com](https://www.emailjs.com)

Get:

* SERVICE_ID
* TEMPLATE_ID
* PUBLIC_KEY

Add keys inside:

```
email_service.dart
```

---

### 6️⃣ Run Project

```
flutter run
```

---

## 🔐 Authentication Flow

* Firebase Auth handles login & registration
* Role-based redirection:

  * Student → Student Dashboard
  * Teacher → Teacher Dashboard
  * Admin → Admin Panel

---

## 📬 Email Notification Flow

When student submits assignment:

```
Student Submit ➜ Firestore Save ➜ Fetch Teacher Email ➜ EmailJS API ➜ Teacher Receives Email
```

---

## 📊 Assignment Targeting System

Teachers can assign work only to selected students:

Example:

```
Target Year: Third Year
Target Department: IT
```

Only matching students can view the assignment.

---

## 🏗 Database Structure (Firestore)

```
users/
 ├── students/data/{uid}
 ├── teachers/data/{uid}

assignments/{assignmentId}

submissions/{assignmentId_studentId}

notifications/{notificationId}
```

---

## 🎯 Highlights

* Role Based Dashboards
* Targeted Assignment Delivery
* Email Notification System
* Realtime Firestore Streams
* CSV Export Feature
* Cloud File Upload
* Performance Optimized Queries

---

## 📸 Screenshots

(Add your app screenshots here)

---

## 👨‍💻 Developer

**Name:** Vivek Patil

**GitHub:** [https://github.com/VivekPatil-2006](https://github.com/VivekPatil-2006)

**LinkedIn:** [https://linkedin.com/in/vivekpatil06](https://linkedin.com/in/vivekpatil06)

---

## ⭐ Support

If you like this project:

* Star the repository ⭐
* Fork it 🍴
* Share with others 🚀

---

## 📄 License

This project is open-source and available for educational purposes.

---

### ✅ Project Status: Production Ready

---

Happy Coding 💙 Flutter + Firebase 🚀
