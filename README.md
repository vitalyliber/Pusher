# README

1. Install VSCode

2. Open DevContainer

3. Run the Rails server

```bash
bin/rails server
```

4. Run the Tailwind process

```bash
bin/rails tailwindcss:watch
```

5. Extract the production DB

```bash
rails db:schema:load

pg_restore --verbose --clean --no-acl --no-owner -h postgres -p 5432 -U postgres -d pusher_development < rpush
```