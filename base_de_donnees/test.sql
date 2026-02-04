-- Insertion d'exemples dans users
INSERT INTO users (
  username,
  hashed_password,
  first_name,
  last_name,
  email,
  address,
  consent_given,
  consent_date,
  consent_version,
  is_active,
  created_at,
  last_login_at
)
VALUES (
  'test_old_user',
  '$2b$12$abcdefghijklmnopqrstuv', -- hash bcrypt factice
  'Test',
  'Ancien',
  'test_old_user@example.com',
  '1 rue du Test',
  TRUE,
  NOW() - INTERVAL '2 year',
  'v1.0',
  TRUE,
  NOW() - INTERVAL '2 year',
  NOW() - INTERVAL '2 year'
);