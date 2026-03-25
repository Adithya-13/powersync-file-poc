# POW-20 Verification: Offline-First Attachment Lifecycle

## Test Setup
1. Run app: `flutter run -d 155F4626-34E0-4734-AD41-E41567E6BF63` (iPhone 17 Pro Max simulator)
2. Open Supabase Storage dashboard to verify file uploads/deletes
3. Observe UI state indicators in todo items:
   - "Uploading" chip (orange) = `QUEUED_UPLOAD`
   - "Synced" chip (green) = `SYNCED`
   - "Downloading photo..." = `QUEUED_DOWNLOAD`

---

## Scenario 1: Upload while offline

### Steps:
1. **Turn off network** on simulator
2. Create a new todo (e.g., "Test offline upload")
3. Click photo icon → select an image from gallery
4. **Verify:**
   - [ ] Photo appears immediately (local file visible)
   - [ ] "Uploading" chip is shown
   - [ ] Todo's `photo_id` is set in local DB
5. **Turn on network**
6. **Verify:**
   - [ ] "Uploading" chip changes to "Synced"
   - [ ] File appears in Supabase Storage dashboard
   - [ ] File path: `attachments/[user_id]/[attachment_id].jpg`

---

## Scenario 2: Download on new device

### Steps:
1. **Clear app data:**
   - Stop the app
   - Run: `flutter run -d 155F4626-34E0-4734-AD41-E41567E6BF63` with `--clean` or delete app from simulator
2. Launch app fresh (same user via anonymous auth)
3. **Verify:**
   - [ ] App authenticates successfully (anonymous auth)
   - [ ] Todos sync from Supabase (photo_id references visible)
   - [ ] "Downloading photo..." text with spinner appears
   - [ ] Photo loads and displays locally
   - [ ] State changes from "Downloading" to "Synced"

---

## Scenario 3: Delete while offline

### Steps:
1. **Turn off network** on simulator
2. Delete a photo from a todo (click X on photo thumbnail)
3. **Verify:**
   - [ ] Photo disappears from UI immediately
   - [ ] Todo's `photo_id` is cleared locally
   - [ ] Attachment marked for deletion (state = `QUEUED_DELETE`)
4. **Turn on network**
5. **Verify:**
   - [ ] File is deleted from Supabase Storage dashboard

---

## Scenario 4: App restart during upload

### Steps:
1. Create a todo and attach a photo
2. **Immediately kill the app** (stop in Xcode/VSCode or Cmd+. in simulator)
3. **Relaunch app:** `flutter run -d 155F4626-34E0-4734-AD41-E41567E6BF63`
4. **Verify:**
   - [ ] App opens without crashes
   - [ ] Photo is still visible (local file preserved)
   - [ ] Queue resumes and upload completes
   - [ ] "Uploading" → "Synced" transition occurs
   - [ ] File appears in Supabase Storage

---

## Debug Queries (for verification)

If UI state is unclear, check DB directly:
```sql
-- Check attachment states
SELECT id, state, local_uri, has_synced FROM attachments;

-- Check todo-photo references
SELECT id, description, photo_id FROM todos WHERE photo_id IS NOT NULL;
```

---

## Commands

```bash
# Run app
flutter run -d 155F4626-34E0-4734-AD41-E41567E6BF63

# Toggle network on simulator
# Device → Toggle Network Condition → 100% Loss (off)
# Device → Toggle Network Condition → None (on)
```
