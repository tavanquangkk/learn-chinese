# Learn Chinese WebApp 🇨🇳

A full-stack application for learning Chinese (HSK Levels), featuring interactive vocabulary practice, pronunciation (TTS), and an AI Chatbot assistant powered by Google Gemini.

## 🏗 Architecture

*   **Frontend**: Flutter Web (Responsive, Material Design 3).
*   **Backend**: Java Spring Boot (REST API, H2 Database, Spring Data JPA).
*   **AI**: Google Gemini API (for chatbot and explanations).
*   **Data**: CSV-based vocabulary import (HSK 1, 2, 3).

---

## ✨ Features

*   **Vocabulary Learning**:
    *   Categorized by HSK Levels (1, 2, 3).
    *   **Pagination**: Vocabulary lists are split into manageable parts (50 words/page).
    *   **Search**: Real-time search by Simplified Chinese, Pinyin, or Meaning.
    *   **Pronunciation (TTS)**: Native browser Text-to-Speech with **Voice Selection** (Male/Female depending on OS/Browser voices).
    *   **Progress Tracking**: Mark words as "Remembered". They fade out and move to the bottom. State is saved persistently.
    *   **Copy Support**: Selectable text for easy copying to dictionaries.

*   **AI Assistant**:
    *   Chat interface to ask grammatical questions or usage examples.
    *   Powered by Google Gemini 1.5 Flash.

---

## 🚀 Prerequisites

1.  **Java 21+** (JDK)
2.  **Maven** (for Backend)
3.  **Flutter SDK** (Channel stable)
4.  **Gemini API Key** (Get one from [Google AI Studio](https://aistudio.google.com/))

---

## 🛠️ Backend Setup (Spring Boot)

The backend manages the database (H2), imports CSV data, and proxies requests to Gemini.

### 1. Configuration
Open `backend/src/main/resources/application.properties` and verify/update:

```properties
server.port=8080
# Database (File-based, persistent)
spring.datasource.url=jdbc:h2:file:./data/learnchinesedb;DB_CLOSE_ON_EXIT=FALSE;AUTO_RECONNECT=TRUE

# Gemini API Key (Set this env var or replace directly)
gemini.api.key=${GEMINI_API_KEY}
```

### 2. Prepare Data
Place your vocabulary CSV files in `backend/src/main/resources/`:
*   `hsk1.csv`
*   `hsk2.csv`
*   `hsk3.csv`

**CSV Format:**
```csv
Simplified,Traditional,Pinyin with numbers,Pinyin,Meaning
你好,你好,ni3 hao3,nǐ hǎo,Hello
...
```

### 3. Run Backend

```bash
cd backend

# Export API Key (Mac/Linux)
export GEMINI_API_KEY=your_actual_api_key_here

# Run
mvn spring-boot:run
```

*Note: If you need to re-import data (e.g., after changing CSVs), stop the server and delete the `backend/data` folder before restarting.*

---

## 💻 Frontend Setup (Flutter Web)

The frontend provides the user interface.

### 1. Install Dependencies

```bash
cd frontend
flutter pub get
```

### 2. Run on Chrome

```bash
flutter run -d chrome
```

---

## 📱 Usage Guide

1.  **Start the Backend first**, then the **Frontend**.
2.  **Vocabulary Tab**:
    *   Select **HSK 1, 2, or 3** tabs.
    *   Use the **Part** chips (Part 1, Part 2...) to navigate pages.
    *   Click the **Speaker 🔊** icon to hear pronunciation.
    *   Click the **Settings ⚙️** icon in the app bar to change the TTS Voice (Male/Female).
    *   Toggle the **Switch** to mark a word as remembered.
3.  **Chat Tab**:
    *   Type questions like "Explain the difference between 二 and 两" to get answers from Gemini.

## 🐛 Troubleshooting

*   **TTS Voice wrong?** Click the ⚙️ icon in the top right corner and select a specific "Google Chinese" or system Chinese voice.
*   **"Database already contains items"?** Stop backend -> `rm -rf backend/data` -> Start backend to re-import CSVs.
*   **CORS Error?** Ensure you restarted the backend after the latest code changes.

---

Enjoy learning! 🇨🇳
