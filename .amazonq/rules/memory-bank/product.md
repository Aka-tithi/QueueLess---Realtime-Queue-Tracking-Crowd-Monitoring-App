# QueueLess - Product Overview

## Purpose
QueueLess is a Flutter mobile application that helps users in Bangladesh check real-time queue lengths and estimated wait times at public service locations — hospitals, banks, and government offices — before physically visiting, eliminating unnecessary waiting.

## Value Proposition
- See live queue status (empty / moderate / busy) before leaving home
- View estimated wait times in minutes for any location
- Save favorite locations for quick access
- Search across all supported locations by name or category

## Key Features
- **Real-time queue data** via Supabase Realtime streams
- **Location browsing** — Popular (top-rated) and Nearby sections on home screen
- **Search** — filter locations by name, category, or address
- **Favorites** — toggle and persist favorite locations per user
- **Queue check-in / check-out** — record user visits with timestamps
- **Authentication** — email/password login and registration via Supabase Auth, with password reset
- **User profile** — display visit stats, average rating, and account info

## Target Users
Residents of Dhaka and other Bangladeshi cities who regularly visit:
- Hospitals (Dhaka Medical, Square, Evercare, etc.)
- Banks (Sonali, BRAC, City Bank, etc.)
- Government offices (Passport Office, BRTA, NID Wing, etc.)

## Location Categories
`Healthcare` | `Banking` | `Government`

## Queue Status Values
| Status | Meaning |
|--------|---------|
| `empty` | Short or no queue |
| `moderate` | Manageable wait |
| `busy` | Long queue, high wait time |
