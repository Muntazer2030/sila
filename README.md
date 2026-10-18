# Sila (صلة)

**A Windows desktop app for managing an organization's relationships and outreach**, built with Flutter.
Keep every contact (government bodies, NGOs, influencers, academics, public figures, media, private sector and
audience) in one searchable local database, group them into campaigns/events, and see the big picture on a dashboard.

The interface is **Arabic (right-to-left)** and everything is stored **locally on your PC**: no account, no server, no cloud.

> **صلة** منظومة لإدارة علاقات المؤسسة على الكمبيوتر: سجّل جهات الاتصال وصنّفها، نظّم الحملات والفعاليات وادعُ الأشخاص
> إليها، وتابع الإحصائيات. كل البيانات تُحفظ محلياً على جهازك.

---

## Features

- **Contact profiles** with a rich record for each person or entity: name, type, main/sub category, governorate and
  region, phones, email, website, contact person and best contact time, preferred contact method, social links
  (Facebook, Instagram, TikTok, X, YouTube, Snapchat, Telegram, LinkedIn), follower count, verified flag, target
  audience and age group, interaction level, importance, status, relationship rating (1-5), number of past
  collaborations, notes and last-updated date.
- **Organized by category**, each with sub-categories:
  Government bodies · Non-governmental organizations · Influential figures · Academic figures · Public and social
  figures · Audience · Media and platforms · Private sector.
- **Search and filters** by name or phone, category, specialty and governorate, with bulk selection and delete.
- **Campaigns / events**: create a campaign with name, dates and description, then search your contacts and
  **invite** them to it. See the invited list at a glance and remove people any time.
- **Dashboard** with a chart of how your contacts are distributed across categories and quick "add" shortcuts.
- **Excel import and export** (`.xlsx`): export the selected records, or import a sheet into a category.
- **Automatic backups**: pick a folder and a copy of the database is saved there after every change.
  Restore from a previous `.db` file at any time.
- **Password protection**: a login screen and a password required for sensitive actions (such as wiping all data).
- **Reset**: wipe the whole database (password required).

## Getting started

### Requirements

- Windows 10/11 (x64)
- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows/desktop) 3.35+ (Dart `^3.9.2`) with Windows desktop support
  (Visual Studio with the "Desktop development with C++" workload)

### Run

```powershell
git clone https://github.com/Muntazer2030/sila.git
cd sila
flutter pub get
flutter run -d windows
```

### Build a release

```powershell
flutter build windows
```

The app is produced in `build\windows\x64\runner\Release\`.

### First login

The default password is **`123456`**. Change it right away from **Settings → Change password**.

## Where your data lives

- The database is a local SQLite file named `sila_database.db` (via `sqflite_common_ffi`).
- Set an automatic backup folder in **Settings**. Backups are named `Sila_Backup_<timestamp>.db`.
- To move to another PC, copy a backup file and use **Settings → Import database**.

## Project structure

```
lib/
  main.dart                  app start, database init, first backup
  const/colors.dart          colors
  data/database_helper.dart  SQLite: profiles, campaigns, invites, backup/import/wipe
  models/                    ProfileModel, CampaignModel, categories (AppData)
  ui/
    screens/                 login, home (dashboard + category pages), profile edit,
                             campaign details, settings
    widgets/                 shared widgets and statistics widgets
```

## Built with

[Flutter](https://flutter.dev) · [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi) ·
[Syncfusion Flutter Charts](https://pub.dev/packages/syncfusion_flutter_charts) · [excel](https://pub.dev/packages/excel) ·
[file_picker](https://pub.dev/packages/file_picker) · [shared_preferences](https://pub.dev/packages/shared_preferences) ·
[uuid](https://pub.dev/packages/uuid)

> **Note:** Syncfusion's Flutter Charts is free under the Syncfusion Community License for qualifying individuals and
> small companies; check their license terms before using this app commercially.

## Notes

- Your contact data can contain personal information. Keep your database and backups somewhere safe.
- The app was designed for an Arabic interface. The theme uses the *Cairo* font if it is installed on the PC.

## License

No license has been chosen yet. All rights reserved by the author until one is added.
