# PicklePoint — Pickleball Court Reservation & Business Management System

## 1. Business Overview

**PicklePoint** is a commercial-style pickleball court rental and reservation system. Customers can create an account, browse available courts, reserve a time slot, submit payment information, and monitor their bookings. Administrators can manage courts, bookings, users, and manual payment verification.

### Problem Being Solved

Manual court reservations can lead to double bookings, unclear court availability, scattered customer records, and difficulty tracking payment status. PicklePoint centralizes these activities in one web application.

---

## 2. Main Features

### Public Landing Page
- PicklePoint business branding and description
- Court/facility presentation
- Services and benefits
- Call-to-action buttons for booking/login
- Responsive layout for desktop and mobile

### User Accounts
- Customer registration using name, email, and password
- Login and logout
- Supabase Auth handles password authentication
- Two roles: **Admin** and **Customer**
- Protected dashboard and admin-only functions

### Court Management CRUD
Admins can:
- **Create** courts
- **Read** court records
- **Update** court name, type, hourly rate, and availability status
- **Delete** courts with confirmation

### Booking Management
Customers can:
- Select a court
- Select a booking date using the quick-date selector/calendar
- View available and booked time slots
- Reserve a one-hour slot
- Choose GCash or Cash
- Submit a GCash reference number
- View their booking history and status
- Cancel eligible bookings

Admins can:
- View all bookings
- Change booking status
- Review payment submissions
- Mark payments as **Paid**
- Reject payment submissions
- View payment references
- Monitor booking activity and operational statistics

### Payment Verification
The classroom version uses **manual payment verification**:

`Customer books → GCash reference submitted → For verification → Admin reviews → Paid or Rejected`

This does **not** directly charge a customer's GCash account. A production system would integrate an approved payment gateway and perform server-side verification.

### Additional Features
- Prevents duplicate court/date/time bookings at the database level
- Court availability by date
- Booking countdown for active reservations
- Payment-status badges
- Booking-status badges
- Admin operational dashboard
- Recent booking activity
- Today's court status
- Confirmation before destructive actions
- Responsive UI

---

## 3. Technology Stack

- **HTML5**
- **CSS3**
- **Vanilla JavaScript**
- **Supabase Auth**
- **Supabase PostgreSQL**
- **Supabase Row Level Security (RLS)**
- **GitHub Pages**
- **Supabase JavaScript CDN**

No backend server is required for the classroom deployment; Supabase provides the authentication and database services.

---

## 4. Project Files

```text
index.html   → Complete front-end application
schema.sql   → Supabase tables, policies, trigger, and seed courts
README.md    → Project documentation and setup guide
```

---

## 5. Supabase Database

The database contains the following core tables:

- `profiles` — customer/admin profile information and roles
- `courts` — court information, rates, and availability status
- `bookings` — reservations, payment information, and booking status

The `bookings` table includes:

- `booking_date`
- `start_time`
- `duration_minutes`
- `total_amount`
- `payment_method`
- `payment_reference`
- `payment_status`
- `status`

A database uniqueness constraint prevents duplicate reservations for the same court, date, and starting time.

---

## 6. Setup Instructions

### Step 1 — Create Supabase Project

Create a project using [Supabase](https://supabase.com/).

### Step 2 — Create the Database

In Supabase:

1. Open **SQL Editor**.
2. Open/copy `schema.sql`.
3. Run the complete SQL script.

This creates the tables, trigger, security policies, and default courts.

### Step 3 — Get Supabase API Details

In Supabase, open:

**Project Settings → API**

Copy:

- Project URL
- Publishable/anon key

Open `index.html` and replace:

```js
const SUPABASE_URL = "YOUR_SUPABASE_URL";
const SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_KEY";
```

Use the **publishable/anon key only** in the front-end. Never place a Supabase `service_role` key in this website or GitHub repository.

### Step 4 — Configure Authentication

Supabase Authentication should have Email/Password enabled.

For a simple classroom demonstration, email confirmation can be disabled in the Supabase Auth settings. If email confirmation is enabled, newly registered users must confirm their email before logging in.

### Step 5 — Create the Admin Account

1. Register an account normally through the PicklePoint website.
2. Open Supabase **SQL Editor**.
3. Run:

```sql
UPDATE public.profiles
SET role = 'admin'
WHERE email = 'YOUR_ADMIN_EMAIL_HERE';
```

Replace the email with the account that should have administrator access.

### Step 6 — Run Locally

The project is a static website. It can be opened through VS Code Live Server or another local static server.

Example:

```bash
python -m http.server 5500
```

Then open:

```text
http://localhost:5500
```

### Step 7 — Deploy to GitHub Pages

1. Create a GitHub repository.
2. Put `index.html`, `schema.sql`, and `README.md` in the repository root.
3. Commit and push the files to the `main` branch.
4. Open **Settings → Pages**.
5. Select **Deploy from a branch**.
6. Select `main` and `/(root)`.
7. Save.
8. Open the generated GitHub Pages URL.

---

## 7. Demo/Test Accounts

Create the actual accounts that will be used during the presentation and put their credentials here before submission.

### Admin

- Email: `YOUR_ADMIN_DEMO_EMAIL`
- Password: `YOUR_ADMIN_DEMO_PASSWORD`
- Role: `admin`

### Customer

- Email: `YOUR_CUSTOMER_DEMO_EMAIL`
- Password: `YOUR_CUSTOMER_DEMO_PASSWORD`
- Role: `customer`

**Do not use placeholder credentials during the actual demonstration.** Replace them with the test accounts created in your Supabase project.

---

## 8. Suggested Demonstration Flow

### Customer Demonstration

1. Open the PicklePoint landing page.
2. Show the court/facility information.
3. Register or log in as a customer.
4. Open **Book a Court**.
5. Select a date.
6. Show available and booked slots.
7. Select a court and time.
8. Select **GCash**.
9. Enter a payment reference number.
10. Submit the booking.
11. Open **My Bookings**.
12. Show the payment status as **For verification**.

### Admin Demonstration

1. Log out.
2. Log in using the admin account.
3. Open **Overview** and show the operational statistics.
4. Open **Manage Courts**.
5. Demonstrate Create, Read, Update, and Delete.
6. Open **Manage Bookings**.
7. Find the customer's `For verification` payment.
8. Click **Review payment**.
9. Show the GCash reference and booking details.
10. Click **Mark as Paid**.
11. Return to the booking/customer view and show the payment status changed to **Paid**.
12. Optionally repeat with another test booking and demonstrate **Reject Payment**.
13. Open **Manage Users** to demonstrate role/user visibility.

---

## 9. Security / Data Notes

- Password authentication is handled by Supabase Auth.
- Passwords are not stored as plain-text application data.
- Row Level Security (RLS) protects customer data and restricts administrative operations.
- Customers can access their own bookings.
- Administrative operations require an admin profile.
- The front-end uses only the Supabase publishable/anon key.
- Never commit a Supabase `service_role` key or other private server secret.

---

## 10. AI Disclosure

AI tools were used during development.

**ChatGPT** was used to assist with:
- system architecture and feature planning
- HTML/CSS/JavaScript generation and refinement
- Supabase database schema design
- RLS/security policy planning
- debugging and troubleshooting
- UI/UX improvements
- documentation drafting

The student reviewed, tested, configured, and customized the implementation and should be able to explain the system's functionality and code during evaluation.

---

## 11. Midterm Rubric Coverage

| Requirement | PicklePoint Implementation |
|---|---|
| Landing Page | Public commercial-style landing page with business information, services, courts, images, CTA, and responsive layout |
| Users | Registration, login/logout, Supabase Auth, Admin/Customer roles, protected features |
| CRUD | Full Court CRUD plus booking creation/read/update/cancellation and admin booking management |
| Working System | Supabase database persistence, RLS, booking validation, duplicate-booking prevention, payment verification |
| Documentation | README, setup instructions, database documentation, test-account section, AI disclosure |
| Originality / Relevance | Pickleball court reservation and operations workflow designed specifically for the business scenario |
| Code Organization | Single static front-end with clearly separated UI sections, Supabase data operations, authentication, booking, court, user, and payment workflows |

---

## 12. Final Submission Checklist

Before submitting the GitHub repository:

- [ ] `index.html` works on GitHub Pages
- [ ] Supabase URL is configured
- [ ] Supabase publishable/anon key is configured
- [ ] No `service_role` key is present in the repository
- [ ] Supabase `schema.sql` has been executed
- [ ] Customer registration works
- [ ] Customer login/logout works
- [ ] Admin login works
- [ ] Admin role is correctly assigned
- [ ] Court Create/Read/Update/Delete works
- [ ] Booking creation works
- [ ] Duplicate booking prevention works
- [ ] GCash reference submission works
- [ ] Payment verification works
- [ ] `Mark as Paid` works
- [ ] `Reject Payment` works
- [ ] Customer sees updated payment status
- [ ] Booking cancellation works
- [ ] Mobile/responsive layout has been checked
- [ ] Test/demo accounts are listed in this README
- [ ] Test bookings used during development are cleaned up or clearly identified
- [ ] AI disclosure is included
- [ ] GitHub repository contains no private secrets

---

## Payment Scope Reminder

PicklePoint's GCash feature is a **manual verification simulation for the classroom project**. It records the customer's payment method and reference number and allows an administrator to approve or reject the submitted payment. It does not directly process or charge GCash accounts.
