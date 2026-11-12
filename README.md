# cs_elective_2

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Local Supabase configuration

Copy `.env.example` to `.env`, then fill in `SUPABASE_URL` and
`SUPABASE_ANON_KEY` from your Supabase project settings. Keep `.env` local; it
is ignored by Git.

## GitHub sign-in

The Products app bar includes a GitHub sign-in/sign-out button backed by
Supabase Auth. To enable it:

1. In Supabase, enable GitHub under **Authentication > Providers** and enter
   the GitHub OAuth app's client ID and client secret.
2. Set the GitHub OAuth app's callback URL to
   `https://<project-ref>.supabase.co/auth/v1/callback`.
3. Add `io.supabase.cs_elective_2://login-callback/` to the Supabase project's
   **Authentication > URL Configuration > Redirect URLs**. For local Flutter
   web development, also allow the local app origin (for example,
   `http://localhost:3000/**`; use the port shown by `flutter run -d chrome`).
4. Configure the Supabase Site URL to your deployed web app URL. Web sign-in
   returns to the current app origin; native Android and iOS sign-in use the
   registered callback scheme.
