# Contributing to Life Reset

Thank you for your interest in improving Life Reset!

## Development Guidelines

1. **Privacy-First Principle:**
   - Life Reset is strictly an offline application.
   - Do not introduce network permissions, cloud synchronizations, analytics SDKs, advertisements, or paid third-party APIs.

2. **Code Style & Verification:**
   - Format all Dart files before committing:
     ```bash
     dart format .
     ```
   - Run the Flutter analyzer and ensure zero issues:
     ```bash
     flutter analyze
     ```
   - Ensure all automated unit and widget tests pass:
     ```bash
     flutter test
     ```

3. **Security Standards:**
   - Never commit keystore files (`*.jks`, `*.keystore`), `key.properties`, passwords, or personal credentials.
   - Respect `.gitignore` rules at all times.
