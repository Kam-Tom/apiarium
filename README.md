# Apiarium
Flutter application for managing beehives.


### Environment Setup
1. Create `.env.dev` file in the root directory
2. Add your Supabase credentials:
```
SUPABASE_URL=your_url_here
SUPABASE_ANON_KEY=your_key_here
```
3. Generate environment configuration:
```bash
dart run build_runner build
```

## Development
To rebuild generated files:
```bash
dart run build_runner build
```