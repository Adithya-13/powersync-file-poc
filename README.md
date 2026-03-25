# PowerSync File Attachments — POC

A Flutter proof-of-concept demonstrating **offline-first file attachment sync** using [PowerSync](https://powersync.com) and [Supabase](https://supabase.com).

The app is a todo list where each item can have a photo attached. Photos are stored locally first, then synced to Supabase Storage in the background — even when the device is offline.

---

## What this demonstrates

| Capability | How it's shown |
|---|---|
| Offline-first data sync | Todos created offline sync to Supabase when connectivity returns |
| File attachment queue | Photos are queued locally and uploaded/downloaded in the background |
| Cross-device sync | Todos + photos appear on all signed-in devices |
| Attachment state tracking | Per-photo badges show: uploading, synced, downloading |
| Error recovery | Retry logic for failed uploads/downloads, skip-on-404 for missing files |
| Anonymous auth | No login screen — Supabase anonymous sessions used automatically |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          Flutter App                            │
│                                                                 │
│  ┌──────────────┐   ┌──────────────────────────────────────┐   │
│  │  Auth Guard  │   │           Todos Page                 │   │
│  │              │   │  [+] add todo  [📷] attach photo     │   │
│  │  Supabase    │   │  ☐ Buy milk         [🟠 uploading]   │   │
│  │  anonymous   │   │  ☑ Walk dog  [photo] [🟢 synced]     │   │
│  │  sign-in     │   │  ☐ Read book                         │   │
│  └──────────────┘   └──────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
          │                          │
          ▼                          ▼
┌─────────────────┐       ┌──────────────────────┐
│  PowerSync SDK  │       │   Attachment Queue   │
│                 │       │                      │
│  SQLite (local) │◄─────►│  watchAttachments()  │
│  ┌───────────┐  │       │  saveFile()          │
│  │  todos    │  │       │  deleteFile()        │
│  │  table    │  │       │  syncInterval: 30s   │
│  ├───────────┤  │       └──────────┬───────────┘
│  │attachment │  │                  │
│  │  _queue   │  │                  ▼
│  └───────────┘  │       ┌──────────────────────┐
└────────┬────────┘       │  SupabaseStorageAdapter│
         │                │                      │
         │ sync           │  upload / download   │
         ▼                │  delete              │
┌─────────────────┐       └──────────┬───────────┘
│  PowerSync      │                  │
│  Service        │                  ▼
│  (JWT bridge)   │       ┌──────────────────────┐
└────────┬────────┘       │  Supabase Storage    │
         │                │  bucket: attachments │
         ▼                │  path: {uuid}.jpg    │
┌─────────────────┐       └──────────────────────┘
│  Supabase       │
│  PostgreSQL     │
│  (todos table)  │
└─────────────────┘
```

### Photo attachment lifecycle

```
User picks photo
      │
      ▼
attachmentQueue.saveFile()
      │
      ├─► Writes file to local storage  (attachments/{uuid}.jpg)
      ├─► Inserts row in attachment_queue  (state = QUEUED_UPLOAD)
      └─► Updates todos.photo_id = {uuid}
                    │
                    │  (background, every 30s or on reconnect)
                    ▼
          SupabaseStorageAdapter.uploadFile()
                    │
                    ├─► success → state = SYNCED
                    └─► failure → AppAttachmentErrorHandler
                                  │
                                  ├─► 404 → state = skip (no retry)
                                  └─► other → retry = true


On another device:
      PowerSync syncs todos row (photo_id arrives)
                    │
                    ▼
          AttachmentQueue sees new photo_id via watchAttachments()
                    │
                    ▼
          Inserts row in attachment_queue  (state = QUEUED_DOWNLOAD)
                    │
                    ▼
          SupabaseStorageAdapter.downloadFile()
                    │
                    ▼
          File saved to local storage, state = SYNCED
```

---

## Project structure

```
lib/
├── main.dart                          # App entry — loads .env, ProviderScope
│
├── core/
│   ├── config/
│   │   └── app_config.dart            # Reads env vars (Supabase URL, PowerSync URL)
│   ├── database/
│   │   ├── schema.dart                # PowerSync schema: todos + attachments_queue
│   │   ├── powersync.dart             # DB init, global `db` + `attachmentsDirectory`
│   │   └── connector.dart             # PowerSyncBackendConnector — JWT + CRUD upload
│   └── attachments/
│       ├── supabase_storage_adapter.dart   # RemoteStorage impl — upload/download/delete
│       ├── attachment_error_handler.dart   # Retry logic per error type
│       ├── attachment_queue_provider.dart  # (unused — superseded by attachments_providers)
│       └── attachments_providers.dart     # AttachmentQueue Riverpod provider + state log
│
└── features/
    ├── auth/
    │   ├── data/datasource/auth_datasource.dart   # Supabase init + anonymous sign-in
    │   └── presentation/
    │       ├── providers/auth_providers.dart       # authInitProvider — full startup sequence
    │       └── widgets/auth_guard.dart             # Loading gate before showing app
    │
    ├── todos/
    │   ├── domain/
    │   │   ├── entity/todo.dart                   # Todo value object
    │   │   ├── repository/todo_repository.dart     # Abstract interface
    │   │   └── usecase/                            # add, toggle, delete, attachPhoto, deletePhoto, watch
    │   ├── data/
    │   │   ├── datasource/todo_datasource.dart     # Raw SQL + attachmentQueue.saveFile/deleteFile
    │   │   └── repository/todo_repository_impl.dart
    │   └── presentation/
    │       ├── providers/todos_providers.dart      # todosProvider, attachmentsProvider, queueSummaryProvider
    │       ├── pages/todos_page.dart               # Main UI
    │       └── widgets/todo_item_widget.dart       # Per-todo card with photo + state badges
    │
    └── debug/
        └── debug_screen.dart          # Attachment inspector (debug builds only)
```

---

## Setup

### Prerequisites

- Flutter SDK ≥ 3.10
- A [Supabase](https://supabase.com) project
- A [PowerSync](https://powersync.com) instance connected to that Supabase project

### 1. Clone and install

```bash
git clone <repo-url>
cd powersync_file_poc
flutter pub get
```

### 2. Configure environment

Copy the example env file and fill in your credentials:

```bash
cp .env.example .env
```

Edit `.env`:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
POWERSYNC_URL=https://your-instance.powersync.journeyapps.com
```

### 3. Set up Supabase

**Create the todos table** (run in Supabase SQL editor):

```sql
CREATE TABLE todos (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_by TEXT NOT NULL,
  description TEXT NOT NULL,
  completed  INTEGER NOT NULL DEFAULT 0,
  photo_id   TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE todos ENABLE ROW LEVEL SECURITY;

-- Allow any authenticated user to read/write all todos
CREATE POLICY "Authenticated users full access"
ON todos FOR ALL TO authenticated
USING (true) WITH CHECK (true);
```

**Create the storage bucket** (in Supabase Dashboard → Storage):

1. Create a bucket named `attachments`
2. Set it to **private**

**Apply the storage policies** (run in SQL editor):

```sql
-- Allow any authenticated user to upload/read/delete attachments
CREATE POLICY "Authenticated users can upload attachments"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'attachments');

CREATE POLICY "Authenticated users can read attachments"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'attachments');

CREATE POLICY "Authenticated users can delete attachments"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'attachments');
```

Or apply via the included migration:

```bash
supabase db push
```

### 4. Configure PowerSync

In your PowerSync dashboard:

1. Connect your Supabase project as the data source
2. Add a sync rule for the `todos` table — example `sync-rules.yaml`:

```yaml
bucket_definitions:
  user_todos:
    data:
      - SELECT * FROM todos
```

3. Copy the PowerSync instance URL into `POWERSYNC_URL` in your `.env`

### 5. Run

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

> **Note:** The app uses anonymous Supabase sign-in — no email/password needed. Each fresh install gets its own anonymous session.

---

## Key dependencies

| Package | Purpose |
|---|---|
| `powersync_core` | Offline-first SQLite sync engine |
| `powersync_flutter_libs` | Native SQLite binaries for mobile |
| `powersync_attachments_helper` | Attachment queue (upload/download/delete lifecycle) |
| `supabase_flutter` | Auth + Storage client |
| `flutter_riverpod` | State management |
| `image_picker` | Camera / gallery photo picker |
| `flutter_dotenv` | `.env` file loading |
| `uuid` | UUID generation for todo + attachment IDs |

---

## Debug screen

In debug builds, tap the bug icon in the app bar to open the **Attachment Debug** screen:

```
┌─────────────────────────────────┐
│       Attachment Debug          │
├─────────────────────────────────┤
│  Cache Info                     │
│  Local storage: 1.2 MB          │
│  Total records: 4               │
├─────────────────────────────────┤
│  [expireCache()]  [verifyAttachments()] │
├─────────────────────────────────┤
│  ● abc123.jpg   SYNCED          │
│  ● def456.jpg   QUEUED_UPLOAD   │
│  ● ghi789.jpg   ARCHIVED        │
└─────────────────────────────────┘
```

- **expireCache()** — marks archived attachments for eviction
- **verifyAttachments()** — restarts sync to re-check all local files against the queue

---

## How offline sync works

```
Device A (online)           PowerSync Service         Device B (offline)
─────────────────           ─────────────────         ──────────────────
User adds todo
  │
  └─► INSERT into           ──── sync ────►           Queued locally
      local SQLite                                          │
  │                                                         │
  └─► PowerSync connector                                   │
      uploadData() called                                   │
      → Supabase upsert ──►  Stored in Postgres            │
                                                            │
                                               Device B reconnects
                                                            │
                                               ◄─── sync ──┘
                                               Row arrives in SQLite
                                               Photo queued for download
                                               SupabaseStorageAdapter
                                               downloads file locally
```

---

## Attachment states

| State | Color | Meaning |
|---|---|---|
| `QUEUED_UPLOAD` | 🟠 orange | File saved locally, waiting to upload |
| `QUEUED_DOWNLOAD` | 🟠 orange | File reference received, waiting to download |
| `QUEUED_DELETE` | 🔴 red | Marked for deletion on remote |
| `SYNCED` | ✅ (no badge) | Local file matches remote |
| `ARCHIVED` | — (hidden) | File no longer referenced, may be evicted |
