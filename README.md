# 🚀 Freely Platform

> **A Modern, Full-Stack, Multi-Platform Freelance Marketplace Ecosystem**

Freely is a comprehensive, production-ready freelance platform connecting clients and skilled freelancers. Built with a decoupled microservice architecture, Freely provides seamless real-time communication, powerful job search and contract management, local payment processing, and high-performance user experiences across Web and Mobile devices.

---

## 🏗️ Architecture & Repository Structure

The project is structured into 4 main specialized modules:

```text
freely-platform/
├── 🌐 ifreely-web/        # Modern SvelteKit Web Application
├── 📱 iFreely-Mobile/     # Cross-Platform Flutter Mobile Application
├── ⚙️ Freely-Backend/      # Apollo GraphQL & Express Primary Backend Server
└── 💬 chatting-api/       # Socket.IO & Express Real-Time Messaging Service
```

### 1. ⚙️ `Freely-Backend` (GraphQL Primary Server)
The core engine powering business logic, user accounts, jobs, contracts, and payment transactions.
- **Framework**: Node.js, Express, Apollo Server 4 (GraphQL)
- **Database**: MongoDB with Mongoose ORM
- **Authentication**: JWT, Session management, Google OAuth 2.0 (Passport.js)
- **Payments**: Integrated with [Chargily Pay](https://chargily.com/) for local/regional gateway transactions.
- **Email & Auth**: Nodemailer for email notifications and password reset tokens.

### 2. 💬 `chatting-api` (Real-Time Chat Microservice)
Dedicated low-latency real-time communication server managing instant messaging between clients and freelancers.
- **Engine**: Node.js, Express, Socket.IO, WebSockets
- **Database**: MongoDB for persistent chat rooms & message logs
- **Notifications**: Firebase Admin SDK for Push Notifications (FCM)
- **Features**: Chat rooms, unread message badges, media metadata, typing indicators.

### 3. 🌐 `ifreely-web` (Web Frontend Client)
A responsive web application for client and freelancer interactions.
- **Framework**: SvelteKit 2, Svelte 4, Vite
- **Styling**: TailwindCSS, Flowbite Svelte, PostCSS
- **Features**: Interactive landing pages, advanced job search & multi-parameter filtering, proposal submission UI, client/freelancer dashboards, and real-time web chat.

### 4. 📱 `iFreely-Mobile` (Mobile Application)
Cross-platform native mobile app for Android and iOS.
- **Framework**: Flutter (Dart)
- **State Management**: Flutter BLoC, GetX, Equatable
- **Local Cache & Storage**: Isar DB, Hive
- **Communication & Media**: Socket.IO client, Audio/Video playback, Voice messaging (`voice_message_package`), image & file pickers, Firebase Messaging (FCM).

---

## ✨ Key Features

- **💼 Job & Contract Management**: Complete lifecycle support from posting jobs and submitting proposals to tracking contract progress and job archiving.
- **💬 Real-Time Messaging & Voice Notes**: Direct instant messaging between clients and freelancers with voice note recording, media uploads, and live status.
- **💳 Local Payment Gateway**: Integrated with Chargily Pay for secure local payments and invoice generation.
- **⭐ Reviews & Trust System**: Ratings, comments, and trust scores for both clients and freelancers.
- **🔔 Push Notifications**: Cross-platform notifications via Firebase Cloud Messaging for messaging, application status, and system alerts.
- **🎯 Multi-Platform Support**: Feature parity across Web (`ifreely-web`) and Mobile (`iFreely-Mobile`).

---

## 🛠️ Technology Stack

| Component | Technologies |
| :--- | :--- |
| **Web Frontend** | SvelteKit, Svelte 4, Vite, TailwindCSS, Flowbite Svelte, Swiper |
| **Mobile App** | Flutter, Dart, BLoC, GetX, Isar DB, Hive, Socket.IO Client |
| **Core Backend** | Node.js, Express, Apollo Server 4, GraphQL, Mongoose, Passport.js |
| **Chat Service** | Node.js, Socket.IO, Firebase Admin SDK, WebSockets |
| **Database** | MongoDB |
| **Payments** | Chargily Pay API |

---

## 🚀 Getting Started

### Prerequisites
Make sure you have the following installed on your machine:
- [Node.js](https://nodejs.org/) (v18+ recommended)
- [MongoDB](https://www.mongodb.com/) (Local or Cloud Atlas instance)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (for mobile development)
- `npm` or `yarn`

---

### 📥 1. Clone the Repository
```bash
git clone https://github.com/T4F0/Freely-platform.git
cd Freely-platform
```

---

### ⚙️ 2. Setting Up `Freely-Backend`
```bash
cd Freely-Backend
npm install
```
- Create a `.env` file inside `Freely-Backend` with:
  ```env
  PORT=4000
  MONGO_URI=mongodb://localhost:27017/freely
  JWT_SECRET=your_jwt_secret
  CHARGILY_API_KEY=your_chargily_key
  GOOGLE_CLIENT_ID=your_google_client_id
  GOOGLE_CLIENT_SECRET=your_google_client_secret
  ```
- Start the server:
  ```bash
  npm start
  ```

---

### 💬 3. Setting Up `chatting-api`
```bash
cd chatting-api
npm install
```
- Create a `.env` file inside `chatting-api` with:
  ```env
  PORT=5000
  MONGO_URI=mongodb://localhost:27017/freely_chat
  JWT_SECRET=your_jwt_secret
  ```
- Start the chat microservice:
  ```bash
  npm start
  ```

---

### 🌐 4. Setting Up `ifreely-web`
```bash
cd ifreely-web
npm install
npm run dev
```
- Open your browser at `http://localhost:5173`.

---

### 📱 5. Setting Up `iFreely-Mobile`
```bash
cd iFreely-Mobile
flutter pub get
flutter run
```

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 👤 Author & Maintainer

Developed with ❤️ by **[B464](https://github.com/T4F0)**.
