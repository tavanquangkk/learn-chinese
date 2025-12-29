# 中国語学習 Webアプリ 🇨🇳

HSKレベル別の単語学習, 発音確認（TTS）, Google Gemini AIを活用したチャットボット機能を備えたフルスタックアプリケーションです。

## 🏗 アーキテクチャ

*   **フロントエンド**: Flutter Web (レスポンシブ, Material Design 3)
*   **バックエンド**: Java Spring Boot (REST API, H2 Database, Spring Data JPA)
*   **AI**: Google Gemini API (チャットボットおよび解説用)
*   **データ**: CSVベースの単語インポート (HSK 1, 2, 3)

---

## ✨ 主な機能

*   **単語学習**:
    *   HSKレベル別カテゴリ (1, 2, 3)
    *   **ページネーション**: 単語リストを50語ごとのパートに分割
    *   **検索**: 簡体字, ピンイン, 意味によるリアルタイム検索
    *   **発音 (TTS)**: ブラウザ標準の読み上げ機能。**音声選択**（男性/女性など）が可能
    *   **進捗管理**: 「覚えた」単語をマーク。マークされた単語はリストの下部に移動し, グレーアウトされます
    *   **テキスト選択**: 外部辞書で調べるためのコピーが容易な `SelectionArea` を採用

*   **AI アシスタント**:
    *   文法の質問や例文の作成を依頼できるチャットインターフェース
    *   Google Gemini 1.5 Flash を使用

---

## 🚀 事前準備

1.  **Java 21+** (JDK)
2.  **Maven** (バックエンド用)
3.  **Flutter SDK** (stable チャンネル)
4.  **Gemini API Key** ([Google AI Studio](https://aistudio.google.com/) で取得)

---

## 🛠️ バックエンドの設定 (Spring Boot)

バックエンドはデータベース(H2)の管理, CSVデータのインポート, Gemini APIとの通信を行います。

### 1. 設定
`backend/src/main/resources/application.properties` を開き, 以下の内容を確認・更新してください。

```properties
server.port=8080
# データベース (ファイルベース, 永続化)
spring.datasource.url=jdbc:h2:file:./data/learnchinesedb;DB_CLOSE_ON_EXIT=FALSE;AUTO_RECONNECT=TRUE

# Gemini API キー (環境変数に設定するか, 直接書き換えてください)
gemini.api.key=${GEMINI_API_KEY}
```

### 2. データの準備
CSVファイルを `backend/src/main/resources/` に配置してください。
*   `hsk1.csv`
*   `hsk2.csv`
*   `hsk3.csv`

**CSVフォーマット:**
```csv
Simplified,Traditional,Pinyin with numbers,Pinyin,Meaning
你好,你好,ni3 hao3,nǐ hǎo,こんにちは
...
```

### 3. バックエンドの実行

```bash
cd backend

# APIキーのエクスポート (Mac/Linux)
export GEMINI_API_KEY=chuachacdagiondau

# 実行
mvn spring-boot:run
```

*注意: データを再インポートしたい場合は, サーバーを停止して `backend/data` フォルダを削除してから再起動してください。*

---

## 💻 フロントエンドの設定 (Flutter Web)

### 1. 依存関係のインストール

```bash
cd frontend
flutter pub get
```

### 2. Chrome で実行

```bash
flutter run -d chrome
```

---

## 📱 使い方ガイド

1.  **バックエンドを先に起動**し, その後に **フロントエンド** を起動します。
2.  **単語タブ**:
    *   **HSK 1, 2, 3** タブを選択します。
    *   **Part** チップを使用してページを切り替えます。
    *   **スピーカー 🔊** アイコンをクリックして発音を聞きます。
    *   右上の **設定 ⚙️** アイコンから音声を変更できます。
    *   **スイッチ** を切り替えて単語を「覚えた」状態にします。
3.  **チャットタブ**:
    *   「二と两の違いを教えて」など, Geminiに質問できます。

## 🐛 トラブルシューティング

*   **音声が正しくない場合**: 右上の ⚙️ アイコンから "Google 中国語" またはシステムの中国語音声を選択してください。
*   **"Database already contains items" と表示される**: バックエンドを停止 -> `rm -rf backend/data` -> バックエンド再起動。
*   **CORSエラー**: コード修正後, バックエンドを再起動したか確認してください。