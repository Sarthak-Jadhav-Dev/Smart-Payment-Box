# Kids EduTech LMS — Class Management, Content Delivery & Parent Linking

Implement the core LMS workflows: **Teachers** create classes, enroll students/parents, and upload YT video links & Google Forms assignments. **Students** and **Parents** see their enrolled classes and content. **Students** can link their account to a parent.

## Proposed Changes

### Firestore Data Model

```
users/{uid}
  ├─ firstName, lastName, email, userType, createdAt
  ├─ linkedParentId: string?      ← (Student only) UID of linked parent
  └─ linkedChildIds: string[]     ← (Parent only) UIDs of linked children

classes/{classId}
  ├─ name, description, subject
  ├─ teacherId: string
  ├─ createdAt: timestamp
  └─ enrolledStudents: string[]   ← array of student UIDs
  └─ enrolledParents: string[]    ← array of parent UIDs

classes/{classId}/content/{contentId}
  ├─ title: string
  ├─ type: 'video' | 'assignment'
  ├─ url: string                  ← YT link or Google Forms link
  └─ createdAt: timestamp
```

---

### Core Service Layer

#### [NEW] [firestore_service.dart](file:///c:/Users/User/StudioProjects/kte/lib/services/firestore_service.dart)
Centralized Firestore CRUD:
- `createClass(name, description, subject)` → writes to `classes/`
- `getTeacherClasses(teacherId)` → queries classes where `teacherId == uid`
- `enrollUser(classId, userId, role)` → arrayUnion on `enrolledStudents` or `enrolledParents`
- `getEnrolledClasses(userId, role)` → queries classes where arrays contain uid
- `addContent(classId, title, type, url)` → writes to subcollection `content/`
- `getClassContent(classId)` → reads `content/` subcollection
- `searchUserByEmail(email)` → query `users` by email field
- `linkParentToStudent(studentId, parentId)` → updates both user docs

#### [MODIFY] [pubspec.yaml](file:///c:/Users/User/StudioProjects/kte/pubspec.yaml)
- Add `url_launcher: ^6.2.5` dependency

---

### Role-Based Navigation

#### [MODIFY] [widget_tree.dart](file:///c:/Users/User/StudioProjects/kte/lib/views/widget_tree.dart)
- Fetch current user's `userType` from Firestore on init
- Show role-specific drawer items:
  - **Teacher** → My Classes, Create Class, Settings
  - **Student** → My Classes, Link Parent, Settings
  - **Parent** → My Children, Settings
- Route to role-specific home page
- Maintain existing purple-themed drawer header & Sans font style

---

### Teacher Views

#### [MODIFY] [teacher_dashboard.dart](file:///c:/Users/User/StudioProjects/kte/lib/views/teacher/teacher_dashboard.dart)
- Firestore StreamBuilder listing teacher's classes as styled cards
- FAB to navigate to CreateCourseScreen
- Purple gradient cards with Sans/Poppins fonts, rounded corners

#### [MODIFY] [create_course.dart](file:///c:/Users/User/StudioProjects/kte/lib/views/teacher/create_course.dart)
- Add `subject` field, connect to `FirestoreService.createClass()`
- Styled inputs matching auth page style (rounded, filled white, purple button)

#### [NEW] [class_detail_screen.dart](file:///c:/Users/User/StudioProjects/kte/lib/views/teacher/class_detail_screen.dart)
- Shows class info, enrolled students/parents lists, content list
- Buttons: "Enroll Student/Parent", "Add Content"
- Content items show type icon (video/assignment) + title

#### [NEW] [enroll_user_screen.dart](file:///c:/Users/User/StudioProjects/kte/lib/views/teacher/enroll_user_screen.dart)
- Search by email → shows matching user → confirm enroll
- Filtered to only show Students or Parents

#### [NEW] [add_content_screen.dart](file:///c:/Users/User/StudioProjects/kte/lib/views/teacher/add_content_screen.dart)
- Title, URL fields + type toggle (Video / Assignment)
- Saves to `classes/{classId}/content/`

---

### Student Views

#### [MODIFY] [course_list.dart](file:///c:/Users/User/StudioProjects/kte/lib/views/student/course_list.dart)
- StreamBuilder reading enrolled classes from Firestore
- Styled cards matching existing purple theme

#### [NEW] [class_detail_screen.dart](file:///c:/Users/User/StudioProjects/kte/lib/views/student/class_detail_screen.dart)
- Lists content (videos & assignments) for an enrolled class
- Tap to open URL via `url_launcher`

#### [NEW] [link_parent_screen.dart](file:///c:/Users/User/StudioProjects/kte/lib/views/student/link_parent_screen.dart)
- Search parent by email → confirm link
- Updates both student & parent Firestore docs

---

### Parent Views

#### [MODIFY] [parent_dashboard.dart](file:///c:/Users/User/StudioProjects/kte/lib/views/parent/parent_dashboard.dart)
- Shows linked children cards
- For each child, shows their enrolled classes
- Tap a class to view content

#### [NEW] [child_class_detail.dart](file:///c:/Users/User/StudioProjects/kte/lib/views/parent/child_class_detail.dart)
- Same as student class_detail but read-only view for parent
- Lists videos & assignments, tappable to open URL

---

### Signup Flow Update

#### [MODIFY] [signup.dart](file:///c:/Users/User/StudioProjects/kte/lib/views/auth_pages/signup.dart)
- When `selectedUserType == "Student"`, show optional "Parent Email" field
- On register, if parent email provided, auto-link to parent account
- If parent not found, show message: "Parent account not found — you can link later"

---

## UI Style Guide (Maintained Throughout)

| **Element** | **Value** |
|---|---|
| Seed Color | `Colors.purpleAccent` |
| Backgrounds | `Colors.purple.shade50` |
| Card/Header BG | `Colors.purple.shade300` / `shade200` |
| Button BG | `Colors.purple.shade900` |
| Font (Headings) | `Poppins` (ExtraBold) |
| Font (Body/Labels) | `Sans` (SemiBold) |
| Border Radius | 20–30px cards, StadiumBorder buttons |
| Input Fields | Filled white, rounded 30px border |

---

## Verification Plan

### Automated
```bash
cd c:\Users\User\StudioProjects\kte
flutter analyze
```
This confirms no compile errors or lint warnings.

### Manual Testing
Since this is a Firebase-backed Flutter app, verification requires running on a device/emulator:

1. **Teacher flow**: Sign up as Teacher → Create a class → View it on dashboard → Enroll a student by email → Enroll a parent by email → Add a YT video link → Add a Google Forms assignment link
2. **Student flow**: Sign up as Student → See enrolled class appear → Tap class → See video & assignment → Tap to open URLs
3. **Parent flow**: Sign up as Parent → Student links to parent → Parent sees child → Taps child's class → Sees content
4. **Linking flow**: Student goes to "Link Parent" → Enters parent email → Both accounts reflect the link

> [!IMPORTANT]
> Manual testing requires Firebase project to be configured and Firestore rules set to allow read/write. The user should run the app on an emulator or physical device for end-to-end verification.
